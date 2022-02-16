#!/usr/bin/env nextflow

ds = ['1', '2', '3', '4', '5', '6', '7', '8']


process setup {
    input:
    val ds

    shell:
    """
    mkdir -p $projectDir/golden/ds$ds
    mkdir -p $projectDir/analysis/ds$ds
    ln -s $projectDir/data/ds$ds $projectDir/golden/ds$ds/data
    ln -s $projectDir/data/ds$ds $projectDir/analysis/ds$ds/data
    """
}

process run_mb {
    input:
    val ds

    shell:
    """
    cd $projectDir/golden/ds$ds
    mb -i $projectDir/scripts/run.mb
    cd ..
    """
}
