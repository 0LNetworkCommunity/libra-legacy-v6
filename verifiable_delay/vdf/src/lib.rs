extern crate ramp;
extern crate rand;
extern crate openssl;
mod discriminant;
trait VDF {
    type PublicParameters;
    type SecurityParameter;
    type TimeBound;
    type Input;
    type Output;
    type Proof;
    fn generate(security_parameter: Self::SecurityParameter, time_bound: Self::TimeBound) -> Self::PublicParameters;
    fn solve(parameters: Self::PublicParameters, input: Self::Input) -> (Self::Output, Self::Proof);
    fn verify(parameters: Self::PublicParameters, input: Self::Input, output: Self::Output, proof: Self::Proof) -> Result<(), ()>;
}
#[cfg(test)]
mod tests {
}