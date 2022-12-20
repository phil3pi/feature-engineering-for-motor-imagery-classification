function slope_data = slope(data,dim)
%SLOPE Summary of this function goes here
%   Detailed explanation goes here
[datapoints,channels] = size(data);

if dim == 1
    slope_data = nan(1,channels);
    for c=1:channels
        assert(datapoints > 1, "In order to calculate the slop at least 2 data-points are needed.");
        slope_data(1,c) = (data(datapoints,c)-data(1,c)) / (datapoints - 1);
    end
else
    slope_data = nan(1,datapoints);
    for d=1:datapoints
        assert(channels > 1, "In order to calculate the slop at least 2 data-points are needed.");
        slope_data(1,d) = (data(d,channels)-data(d,1)) / (channels - 1);
    end
end
end

