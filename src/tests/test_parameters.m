r = WaveletEntropyParameters.getPermutations();

obj = WaveletEntropyParameters("shannon", "tranform1");
disp(obj.toString);

r2 = StatisticParameters.getPermutations;

obj2 = StatisticParameters(["min", "max"]);
disp(obj2.toString);

r3 = PsdParameters.getPermutations;

obj3 = PsdParameters(FrequencyBand.getAllBands, StatisticParameters(["min", "max"]));
disp(obj3.toString);

obj4 = WaveletVarianceParameters();
disp(obj4.toString);

r5 = ArParameters.getPermutations;

obj5 = ArParameters("arcov", 14, true);
disp(obj5.toString);

r6 = ArPsdParameters.getPermutations;

obj6 = ArPsdParameters("pcov", 2, StatisticParameters("psd"), FrequencyBand.getAllBands);
disp(obj6.toString);

obj7 = LyapunovParameters();
disp(obj7.toString);
