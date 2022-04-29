#!/bin/bash

command="#NEXUS
Begin mrbayes;
    exe $1;
    set autoclose=yes nowarn=yes;
    lset nst=1 rates=equal;
    mcmcp ngen=10000 samplefreq=100 printfreq=100 diagnfreq=100 file=DS;
    prset statefreqpr=fixed(equal) topologypr=uniform;
    prset brlenspr = unconstrained:gammadir(1.,.1,1.,1.);
    propset ExtTBR(Tau,V)\$prob=0;
    propset NNI(Tau,V)\$prob=0;
    
    mcmc;
    sump burnin=1000;
    sumt burnin=1000;
end;"
touch run.mb
echo "$command" > run.mb
