load ../../../test/common


setup() {
    scope standard 
    prequisites_ok rstudio
}


# Start the rstudio server
@test "${ch_tag}/start" {
    ch-run "$ch_img" -- start_rstudio 8181
}


