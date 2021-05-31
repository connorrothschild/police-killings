import 'https://deno.land/x/flat@0.0.10/mod.ts'

// Installs necessary packages
const r_install = Deno.run({
    cmd: ['sudo', 'Rscript', '-e', "install.packages(c('dplyr', 'readxl', 'readr', 'lubridate', 'stringr'))"]
});

await r_install.status();

// Forwards the execution to the R script
const clean = Deno.run({
    cmd: ['Rscript', './update-data/clean-data.R']
});

await clean.status();

// Forwards the execution to the R script
const departments = Deno.run({
    cmd: ['Rscript', './update-data/pull-departments.R']
});

await departments.status();
