r = WaveletEntropyParameters.getPermutations();

obj = WaveletEntropyParameters("shannon","tranform1",4);
disp(obj.toString);

r2 = StatisticParameters.getPermutations;

obj2 = StatisticParameters(["min","max"]);
disp(obj2.toString);

r3 = PsdParameters.getPermutations;

obj3 = PsdParameters(FrequencyBand.getAllBands,StatisticParameters(["min","max"]));
disp(obj3.toString);