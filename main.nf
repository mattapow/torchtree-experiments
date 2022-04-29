#!/usr/bin/env nextflow

params.analysis = "$baseDir/analysis"
params.data = "$baseDir/data"
params.iterations = 1000
ds = Channel.of('DS1', 'DS2', 'DS3', 'DS4', 'DS5', 'DS6', 'DS7', 'DS8')


process PREPARE_TORCHTREE {
    label 'ds'

    input:
    val ds

    output:
    path "torchtree.${ds}.json"

    script:
    """
    torchtree-cli advi \
        -i ${params.data}/${ds}/DS.fasta \
        -t ${params.data}/${ds}/DS.treefile \
        --clock strict \
        --dates 0 \
        --coalescent skyride \
        --heights ratio \
        --heights_init tree \
        --eta 0.0001 \
        --elbo_samples 1 \
        --grad_samples 1 \
        --iter ${params.iterations} \
        > torchtree.${ds}.json
    """
}

 process RUN_TORCHTREE {
  label 'ds'

  publishDir "$params.analysis/${ds}/torchtree", mode: 'copy'

  input:
  path "torchtree.${ds}.json"
  val ds

  output:
  file "stdout.log"
  file "time.log"
  file "samples.csv"
  """
  { time \
  torchtree torchtree.${ds}.json > stdout.log ; } 2> time.log & exit 0
  """
}

process RUN_MB {
    publishDir "$params.analysis/$ds/mb", mode: 'copy'

    input:
    val ds

    script:
    """
    mkdir -p $params.analysis/${ds}/mb
    cd $params.analysis/${ds}/mb
    $baseDir/mb_template.sh $baseDir/data/${ds}/DS.nex
    mb -i run.mb

    mkdir sumt
    mv DS.trprobs sumt/DS.trprobs
    mv DS.parts sumt/DS.parts
    mv DS.con.tre sumt/DS.con.tre
    mkdir sump
    mv DS.tstat sump/DS.tstat
    mv DS.vstat sump/DS.vstat
    mv DS.lstat sump/DS.lstat
    mv DS.pstat sump/DS.pstat
    """
}

process SETUP {
  input:
  val ds

  script:
  """
  for ds in {1..8};
  do
    mkdir -p analysis/DS${ds}
  done
  """

}

workflow {
  SETUP(ds)
  PREPARE_TORCHTREE(ds)
  RUN_TORCHTREE(PREPARE_TORCHTREE.out, ds)
  RUN_MB(ds)
}
