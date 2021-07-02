function Dist = DiscreteDist(Probabilities, Values)
% Returns a (dummy) Distribution for a discrete Random Variable
% (only the random function is implemented so far)
%
% Input: 
%     Probabilities ... Column Vector of probabilities
%     Values        ... Column Vecotr of associated Values

assert(all(size(Probabilities) == size(Values) ));

Dist = struct();
Dist.random = @(varargin) discrete_random( [Probabilities, Values], varargin{:} ) ;

Dist.mean = sum(Probabilities .* Values);

tmp  = Values - Dist.mean;
Dist.var = sum(Probabilities .* tmp.^2);