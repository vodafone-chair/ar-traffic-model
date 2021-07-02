function samples = discrete_random(pmf_table, varargin)
% samples random values according to a given pmf_table
%
% pmf_table(:,1) ... probabilities
% pmf_table(:,2) ... values
%
% varargin ... desired dimensions (same as the builtin random(...))

r = rand(varargin{:});

samples = nan(size(r));

cdf = cumsum(pmf_table(:,1));
cdf = cdf / cdf(end); % normalize to 1, if necessary.

for si = 1:numel(samples)
    ind = find( r(si) < cdf, 1, 'first');
    samples(si) = pmf_table(ind,2);
end
    