# Default R-version install via rocker, uses debian as a base
FROM rocker/verse:3.6.1

# Prepare the Rstudio authentication script
COPY ./rstudio_auth.sh /bin/
RUN chmod +x /bin/rstudio_auth.sh && \
  ln -s -r /bin/rstudio_auth.sh /bin/rstudio_auth

# Prepare the rstudio start script
COPY ./start_rstudio.sh /bin/
RUN chmod +x /bin/start_rstudio.sh && \
  ln -s -r /bin/start_rstudio.sh /bin/start_rstudio
