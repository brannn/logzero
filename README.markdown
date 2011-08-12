logzero
==============

A kit for transmitting, parsing, and storing piped Apache request logs in a database, currently MongoDB or Redis.

Requests are pipelined via a ZeroMQ push/pull socket pair.  The upstream receiver parses each log line and builds a document which is stored in the database.

If the database or upstream receiver becomes unavailable, ZeroMQ ensures that log messages will be queued indefinitely or until a certain threshold has been reached.
See ``` CONF['receiver']['hwm'] ``` in logzero.yml. 
 
Dependencies
==============

__ZeroMQ__: ``` gem install zeromq ```

A  __MongoDB__ or __Redis__ database.

If you use Redis, the __redis__ and __ohm__ gems are required.
If you use MongoDB, the __mongo__ gem is required.
 
__LogFormat__:

```
"%{Server_Addr}e:%p %h %l %{UNIQUE_ID}e %{%Y-%m-%dT%H:%M:%S}t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""
```
...which probably won't be useful to you, so modify as needed. 
 
Usage
==============

Apache config:

```
CustomLog "|/usr/bin/ruby /logzero/bin/logzero_apache.rb" blah
```

On the loghost:

```
./logzero_{mongodb|redis}.rb
```

Credit
==============

Parts, especially the parser, lifted from Slicertje's ApacheMongoLogger
