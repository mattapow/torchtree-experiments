#!/usr/bin/env nextflow

params.results = "$baseDir/results"
params.data = "$baseDir//data"
params.iterations = 5000
ds = Channel.of('DS1', 'DS2', 'DS3', 'DS4', 'DS5', 'DS6', 'DS7', 'DS8')

// process SETUP_MB {
//     input:
//     val ds from alignment_datasets

//     output:
//     file "results/$ds" into golden_ready

//     when:
//     file("results/$ds").isEmpty()

//     shell:
//     """
//     mkdir -p ./results/$ds
//     """
// }

// process RUN_MB {
//     echo true

//     input:
//     file golden_ready

//     output:
//     file golden_ready into golden_done

//     // when:
//     // file(golden_dir).isDirectory()

//     shell:
//     """
//     cd $golden_ready
//     mb -i $projectDir/scripts/run.mb
//     cd ..
//     """
// }

process PREPARE_TORCHTREE {
    label 'ds'

    input:
    val ds
    output:
    path("torchtree.${ds}.json")
    script:
    // TODO: add DS.treefile with same taxon names.
    // Torchtree-cli: local variable 'taxon' referenced before assignment
    """
    torchtree-cli advi \
        -i ${params.data}/${ds}/DS.nex \
        -t ${params.data}/${ds}/DS.treefile \
        --clock strict \
        --coalescent skyride \
        --heights ratio\
        --eta 0.0001 \
        --elbo_samples 1 \
        --grad_samples 1\
        --iter ${params.iterations}
    """
}

 process RUN_TORCHTREE {
  label 'ds'

  publishDir "$params.results/$it/torchtree", mode: 'copy'

  input:
  tuple file(PREPARE_TORCHTREE.out), val ds
  output:
  path("torchtree.${ds}.txt")
  path("torchtree.${ds}.log")
  """
  { time \
  torchtree $torchtree_json > torchtree.${bito}.${size}.${rep}.txt ; } 2> torchtree.${bito}.${size}.${rep}.log
  """
}
