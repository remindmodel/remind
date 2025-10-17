from internalizer import Internalizer

EI_VERSION = "3.10"

# set paths a previous run
mifpath = "/p/tmp/davidba/internalization_develop/remind/output/SSP2-NPi-internalize-test-MAC-pm05_2025-08-14_06.36.38/lca/remind_runs/remind_SSP2-NPi-internalize-test-MAC-pm05.mif"
pathway = "SSP2-NPi-internalize-test-MAC-pm05"
gdxpath = "/p/tmp/davidba/internalization_develop/remind/output/SSP2-NPi-internalize-test-MAC-pm05_2025-08-14_06.36.38/fulldata.gdx"

# in any case, initialize an Internalizer instance and call the setup
bw_project = f"internalizer_ei_{EI_VERSION}"
I = Internalizer(
    mifpath,
    "remind",
    pathway,
    EI_VERSION,
    bw_project,
    gdxpath,
    outputfolder = "lca"
)

I.recreate_premise_cache()