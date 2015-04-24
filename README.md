ZNC-compose
===

docker-compose setup to run ZNC in a Docker container. Includes the `znc-otr` and `znc-push` modules.

### Configuration

To import your current configurations, add your current `.znc` folder as a subfolder of `data` and uncomment the `ADD` directive in `data/Dockerfile`. Switch the `data` container to `build` in `docker-compose.yml`, and run `docker-compose build data` to create your data container. Do this only once, and don't forget to go back to using `image` instead of `build` in `docker-compose.yml`.

If you prefer to use a host volume, comment the `volumes_from` section, uncomment the `volumes` one and adjust to your path locations if needed.

### Building and running

Simply run the usual `docker-compose up`
