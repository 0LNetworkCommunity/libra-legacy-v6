use std::{collections::HashMap, rc::Rc};

use serde::Deserialize;

use crate::{types::Type, Value};

/// ABI decoded param value.
#[derive(Debug, Clone, Eq, PartialEq)]
pub struct DecodedParam {
    // Param definition.
    pub param: Param,
    // Decoded param value.
    pub value: Value,
}

impl From<(Param, Value)> for DecodedParam {
    fn from((param, value): (Param, Value)) -> Self {
        Self { param, value }
    }
}

/// ABI decoded values. Fast access by param index and name.
///
/// This struct provides a way for accessing decoded param values by index and by name.
#[derive(Debug, Clone, Eq, PartialEq)]
pub struct DecodedParams {
    pub index_params: Vec<Rc<DecodedParam>>,
    pub named_params: HashMap<String, Rc<DecodedParam>>,
}

impl From<Vec<(Param, Value)>> for DecodedParams {
    fn from(values: Vec<(Param, Value)>) -> Self {
        let index_params: Vec<Rc<DecodedParam>> =
            values.into_iter().map(From::from).map(Rc::new).collect();

        let named_params = index_params
            .iter()
            .filter(|decoded_param| !decoded_param.param.name.is_empty())
            .cloned()
            .map(|decoded_param| (decoded_param.param.name.clone(), decoded_param))
            .collect();

        Self {
            index_params,
            named_params,
        }
    }
}

/// A definition of a parameter of a function or event.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Param {
    /// Parameter name.
    pub name: String,
    /// Parameter type.
    pub type_: Type,
    /// Whether it is an indexed parameter (events only).
    pub indexed: Option<bool>,
}

impl<'a> Deserialize<'a> for Param {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: serde::Deserializer<'a>,
    {
        let entry: ParamEntry = Deserialize::deserialize(deserializer)?;

        let (_, ty) = parse_exact_type(Rc::new(entry.components), &entry.type_)
            .map_err(|e| serde::de::Error::custom(e.to_string()))?;

        Ok(Param {
            name: entry.name.to_string(),
            type_: ty,
            indexed: entry.indexed,
        })
    }
}

#[derive(Debug, Clone, Deserialize)]
struct ParamEntry {
    pub name: String,
    #[serde(rename = "type")]
    pub type_: String,
    pub indexed: Option<bool>,
    pub components: Option<Vec<ParamEntry>>,
}

use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{char, digit1},
    combinator::opt,
    combinator::{map_res, recognize, verify},
    exact,
    multi::many1,
    sequence::delimited,
    IResult,
};

#[derive(Debug)]
enum TypeParseError<I> {
    Error,
    NomError(nom::error::Error<I>),
}

impl<I> From<nom::error::Error<I>> for TypeParseError<I> {
    fn from(err: nom::error::Error<I>) -> Self {
        Self::NomError(err)
    }
}

impl<I> nom::error::ParseError<I> for TypeParseError<I> {
    fn from_error_kind(input: I, kind: nom::error::ErrorKind) -> Self {
        Self::NomError(nom::error::Error::new(input, kind))
    }

    fn append(_: I, _: nom::error::ErrorKind, other: Self) -> Self {
        other
    }
}

type TypeParseResult<I, O> = IResult<I, O, TypeParseError<I>>;

fn map_error<I, O>(res: IResult<I, O>) -> TypeParseResult<I, O> {
    res.map_err(|err| err.map(From::from))
}

fn parse_exact_type(
    components: Rc<Option<Vec<ParamEntry>>>,
    input: &str,
) -> TypeParseResult<&str, Type> {
    exact!(input, parse_type(components.clone()))
}

fn parse_type(
    components: Rc<Option<Vec<ParamEntry>>>,
) -> impl Fn(&str) -> TypeParseResult<&str, Type> {
    move |input: &str| {
        alt((
            parse_array(components.clone()),
            parse_simple_type(components.clone()),
        ))(input)
    }
}

fn parse_simple_type(
    components: Rc<Option<Vec<ParamEntry>>>,
) -> impl Fn(&str) -> TypeParseResult<&str, Type> {
    move |input: &str| {
        alt((
            parse_tuple(components.clone()),
            parse_uint,
            parse_int,
            parse_address,
            parse_bool,
            parse_string,
            parse_bytes,
        ))(input)
    }
}

fn parse_uint(input: &str) -> TypeParseResult<&str, Type> {
    map_error(
        verify(parse_sized("uint"), check_int_size)(input).map(|(i, size)| (i, Type::Uint(size))),
    )
}

fn parse_int(input: &str) -> TypeParseResult<&str, Type> {
    map_error(
        verify(parse_sized("int"), check_int_size)(input).map(|(i, size)| (i, Type::Int(size))),
    )
}

fn parse_address(input: &str) -> TypeParseResult<&str, Type> {
    map_error(tag("address")(input).map(|(i, _)| (i, Type::Address)))
}

fn parse_bool(input: &str) -> TypeParseResult<&str, Type> {
    map_error(tag("bool")(input).map(|(i, _)| (i, Type::Bool)))
}

fn parse_string(input: &str) -> TypeParseResult<&str, Type> {
    map_error(tag("string")(input).map(|(i, _)| (i, Type::String)))
}

fn parse_bytes(input: &str) -> TypeParseResult<&str, Type> {
    let (i, _) = map_error(tag("bytes")(input))?;
    let (i, size) = map_error(opt(verify(parse_integer, check_fixed_bytes_size))(i))?;

    let ty = size.map_or(Type::Bytes, Type::FixedBytes);

    Ok((i, ty))
}

fn parse_array(
    components: Rc<Option<Vec<ParamEntry>>>,
) -> impl Fn(&str) -> TypeParseResult<&str, Type> {
    move |input: &str| {
        let (i, ty) = parse_simple_type(components.clone())(input)?;

        let (i, sizes) = map_error(many1(delimited(char('['), opt(parse_integer), char(']')))(
            i,
        ))?;

        let array_from_size = |ty: Type, size: Option<usize>| match size {
            None => Type::Array(Box::new(ty)),
            Some(size) => Type::FixedArray(Box::new(ty), size),
        };

        let init_arr_ty = array_from_size(ty, sizes[0]);
        let arr_ty = sizes.into_iter().skip(1).fold(init_arr_ty, array_from_size);

        Ok((i, arr_ty))
    }
}

fn parse_tuple(
    components: Rc<Option<Vec<ParamEntry>>>,
) -> impl Fn(&str) -> TypeParseResult<&str, Type> {
    move |input: &str| {
        let (i, _) = map_error(tag("tuple")(input))?;

        let tys = match components.clone().as_ref() {
            Some(cs) => cs
                .clone()
                .into_iter()
                .try_fold(vec![], |mut param_tys, param| {
                    let comps = match param.components.as_ref() {
                        Some(comps) => Some(comps.clone()),
                        None => None,
                    };

                    let ty = match parse_exact_type(Rc::new(comps), &param.type_) {
                        Ok((_, ty)) => ty,
                        Err(_) => return Err(nom::Err::Failure(TypeParseError::Error)),
                    };

                    param_tys.push((param.name, ty));

                    Ok(param_tys)
                }),

            None => Err(nom::Err::Failure(TypeParseError::Error)),
        }?;

        Ok((i, Type::Tuple(tys)))
    }
}

fn parse_sized(t: &str) -> impl Fn(&str) -> IResult<&str, usize> + '_ {
    move |input: &str| {
        let (i, _) = tag(t)(input)?;

        parse_integer(i)
    }
}

fn parse_integer(input: &str) -> IResult<&str, usize> {
    map_res(recognize(many1(digit1)), str::parse)(input)
}

fn check_int_size(i: &usize) -> bool {
    let i = *i;

    i > 0 && i <= 256 && i % 8 == 0
}

fn check_fixed_bytes_size(i: &usize) -> bool {
    let i = *i;

    i > 0 && i <= 32
}

#[cfg(test)]
mod test {
    use serde_json::json;

    use super::*;

    #[test]
    fn deserialize_uint() {
        for i in (8..=256).step_by(8) {
            let v = json!({
                "name": "a",
                "type": format!("uint{}", i),
            });

            let param: Param = serde_json::from_value(v).unwrap();

            assert_eq!(
                param,
                Param {
                    name: "a".to_string(),
                    type_: Type::Uint(i),
                    indexed: None
                }
            );
        }
    }

    #[test]
    fn deserialize_int() {
        for i in (8..=256).step_by(8) {
            let v = json!({
                "name": "a",
                "type": format!("int{}", i),
            });

            let param: Param = serde_json::from_value(v).unwrap();

            assert_eq!(
                param,
                Param {
                    name: "a".to_string(),
                    type_: Type::Int(i),
                    indexed: None
                }
            );
        }
    }

    #[test]
    fn deserialize_address() {
        let v = json!({
            "name": "a",
            "type": "address",
        });

        let param: Param = serde_json::from_value(v).unwrap();

        assert_eq!(
            param,
            Param {
                name: "a".to_string(),
                type_: Type::Address,
                indexed: None
            }
        );
    }

    #[test]
    fn deserialize_bool() {
        let v = json!({
            "name": "a",
            "type": "bool",
        });

        let param: Param = serde_json::from_value(v).unwrap();

        assert_eq!(
            param,
            Param {
                name: "a".to_string(),
                type_: Type::Bool,
                indexed: None
            }
        );
    }

    #[test]
    fn deserialize_string() {
        let v = json!({
            "name": "a",
            "type": "string",
        });

        let param: Param = serde_json::from_value(v).unwrap();

        assert_eq!(
            param,
            Param {
                name: "a".to_string(),
                type_: Type::String,
                indexed: None
            }
        );
    }

    #[test]
    fn deserialize_bytes() {
        for i in 1..=32 {
            let v = json!({
                "name": "a",
                "type": format!("bytes{}", i),
            });

            let param: Param = serde_json::from_value(v).unwrap();

            assert_eq!(
                param,
                Param {
                    name: "a".to_string(),
                    type_: Type::FixedBytes(i),
                    indexed: None
                }
            );
        }

        let v = json!({
            "name": "a",
            "type": "bytes",
        });

        let param: Param = serde_json::from_value(v).unwrap();

        assert_eq!(
            param,
            Param {
                name: "a".to_string(),
                type_: Type::Bytes,
                indexed: None
            }
        );
    }

    #[test]
    fn deserialize_array() {
        let v = json!({
            "name": "a",
            "type": "uint256[]",
        });
        let param: Param = serde_json::from_value(v).unwrap();

        assert_eq!(
            param,
            Param {
                name: "a".to_string(),
                type_: Type::Array(Box::new(Type::Uint(256))),
                indexed: None,
            }
        );
    }

    #[test]
    fn deserialize_nested_array() {
        let v = json!({
            "name": "a",
            "type": "address[][]",
        });
        let param: Param = serde_json::from_value(v).unwrap();

        assert_eq!(
            param,
            Param {
                name: "a".to_string(),
                type_: Type::Array(Box::new(Type::Array(Box::new(Type::Address)))),
                indexed: None,
            }
        );
    }

    #[test]
    fn deserialize_mixed_array() {
        let v = json!({
            "name": "a",
            "type": "string[2][]",
        });
        let param: Param = serde_json::from_value(v).unwrap();

        assert_eq!(
            param,
            Param {
                name: "a".to_string(),
                type_: Type::Array(Box::new(Type::FixedArray(Box::new(Type::String), 2))),
                indexed: None,
            }
        );

        let v = json!({
            "name": "a",
            "type": "string[][3]",
        });
        let param: Param = serde_json::from_value(v).unwrap();

        assert_eq!(
            param,
            Param {
                name: "a".to_string(),
                type_: Type::FixedArray(Box::new(Type::Array(Box::new(Type::String))), 3),
                indexed: None,
            }
        );
    }

    #[test]
    fn deserialize_tuple() {
        let v = json!({
          "name": "s",
          "type": "tuple",
          "components": [
            {
              "name": "a",
              "type": "uint256"
            },
            {
              "name": "b",
              "type": "uint256[]"
            },
            {
              "name": "c",
              "type": "tuple[]",
              "components": [
                {
                  "name": "x",
                  "type": "uint256"
                },
                {
                  "name": "y",
                  "type": "uint256"
                }
              ]
            }
          ]
        });

        let param: Param = serde_json::from_value(v).unwrap();

        assert_eq!(
            param,
            Param {
                name: "s".to_string(),
                type_: Type::Tuple(vec![
                    ("a".to_string(), Type::Uint(256)),
                    ("b".to_string(), Type::Array(Box::new(Type::Uint(256)))),
                    (
                        "c".to_string(),
                        Type::Array(Box::new(Type::Tuple(vec![
                            ("x".to_string(), Type::Uint(256)),
                            ("y".to_string(), Type::Uint(256))
                        ])))
                    )
                ]),
                indexed: None,
            }
        )
    }
}
