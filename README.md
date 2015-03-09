Heka - Config
=============

I mainly use this repository to test my [heka](http://hekad.readthedocs.org/)
configuration.

Basically, all lua modules should be symlinked to `/usr/share/heka/<dir>/*.lua`

Then, I use 2 kinds of heka instance:

* The **agent**: It runs on every nodes of my DC. It accepts logs from nginx,
symfony. and it forward everything over TCP to a router.

* The **router**: It runs only one few nodes (just one is enough). It accepts
logs from all agents, performs some stats (thanks to filters) and push almost
everything to Elasticsearch and Graphite.
