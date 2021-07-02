function y = delayedsum(coeff, x)
% calulates the sum_i=1^p coeff_i x_(N-i)
% with p = length(coeff)
%      N = length(X)
%
% if p > N only the first N coeffs are considered
%

coeff = ensure_col(coeff);
x     = ensure_col(x);

p = length(coeff);
N = length(x);

if p > N
    ptilde = N;
else
    ptilde = p;
end

y = sum(  coeff(1:ptilde) .* x(end:-1:end-ptilde+1) );
