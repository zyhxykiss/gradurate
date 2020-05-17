traningfiles = {'audioData\traningSimple\positive','audioData\traningSimple\negative'};
testfiles = {'audioData\testSimple\positive','audioData\testSimple\nagetive'};

%wavfile = read_simple(traningfiles);
%extrafeature(wavfile);

wavfilet = read_simple(testfiles);
extrafeature(wavfilet);

