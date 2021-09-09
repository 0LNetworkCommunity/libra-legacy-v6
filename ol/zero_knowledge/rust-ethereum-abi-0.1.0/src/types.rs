/// Available ABI types.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Type {
    /// Unsigned int type (uint<M>).
    Uint(usize),
    /// Signed int type (int<M>).
    Int(usize),
    /// Address type (address).
    Address,
    /// Bool type (bool).
    Bool,
    /// Fixed size bytes type (bytes<M>).
    FixedBytes(usize),
    /// Fixed size array type (T\[k\])
    FixedArray(Box<Type>, usize),
    /// UTF-8 string type (string).
    String,
    /// Dynamic size bytes type (bytes).
    Bytes,
    /// Dynamic size array type (T[])
    Array(Box<Type>),
    /// Tuple type (tuple(T1, T2, ..., Tn))
    Tuple(Vec<(String, Type)>),
}

impl Type {
    /// Returns whether the given type is a dynamic size type or not.
    pub fn is_dynamic(&self) -> bool {
        match self {
            Type::Uint(_) => false,
            Type::Int(_) => false,
            Type::Address => false,
            Type::Bool => false,
            Type::FixedBytes(_) => false,
            Type::FixedArray(ty, _) => ty.is_dynamic(),
            Type::String => true,
            Type::Bytes => true,
            Type::Array(_) => true,
            Type::Tuple(tys) => tys.iter().any(|(_, ty)| ty.is_dynamic()),
        }
    }
}

impl std::fmt::Display for Type {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Type::Uint(size) => write!(f, "uint{}", size),
            Type::Int(size) => write!(f, "int{}", size),
            Type::Address => write!(f, "address"),
            Type::Bool => write!(f, "bool"),
            Type::String => write!(f, "string"),
            Type::FixedBytes(size) => write!(f, "bytes{}", size),
            Type::Bytes => write!(f, "bytes"),
            Type::FixedArray(ty, size) => write!(f, "{}[{}]", ty, size),
            Type::Array(ty) => write!(f, "{}[]", ty),
            Type::Tuple(tys) => write!(
                f,
                "({})",
                tys.iter()
                    .map(|(_, ty)| format!("{}", ty))
                    .collect::<Vec<_>>()
                    .join(",")
            ),
        }
    }
}
