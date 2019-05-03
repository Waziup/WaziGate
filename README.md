WAZIUP Edge gateway
===================

This repo contains the source code for the Waziup Edge gateway.

Install
-------

To install the platform, first clone it:
```
git clone https://github.com/Waziup/waziup-gateway.git
cd waziup-gateway
```

Then pull the images and run it:
```
docker-compose pull
docker-compose up
```

This will take a while. Once finished, you can access the gateway UI on http://localhost:80

Develop
-------

To get the source code for each submodules, you need to clone with --recursive:
```
# clone with submodules
git clone --recursive git@github.com:Waziup/waziup-gateway.git
cd waziup-gateway
git submodule update --remote --recursive
docker-compose build
```

Tests
-----

You can run the test campain like this:
```
./run_tests.sh
```

Or view the UI:
```
firefox localhost:80
```

