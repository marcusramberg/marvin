# MARVIN

> “Why should I want to make anything up? Life's bad enough as it is without wanting to invent any more of it.” 


# WHO 

* Catalyst co-founder
* Mojolicious core
* Other projects: iusethis, output.digital, mojomojo, convos, meatchat2
* MRAMBERG on CPAN.
* http://marcus.nordaaker.com/


# WHO

- marcus.ramberg@usit.uio.no
- http://people.uio.no/marcusr
- web ops @ usit, uio


# Nordaaker


# Slack



# Jabber


# Why?

* Hubot
* Lita.io
* convos.by


# Mojolicious


* MVC Framework
* Real Time IOLoop
* HTTP Stack
* JSON Pointers
* ASync User Agent
* XML DOM Parser
* AnyEvent/EV integration


```
node^H^H^H^Hio.js
```


Mojolicious::Lite


# ROUTES

- Mojolicious::Routes
- s{\s+}{/}g
- methods: PUBLIC/PRIVATE


# Adapters

* XMPP
* IRC
* Your chat system here?


# Plugins!


Ford Perfect


# MHGTG


Request Tracker


```
<marvin> [www-drift]  supply transformer https://rt.uio.no/Ticket/Display.html?id=1806536
<luser> !take 1806536
<marvin> Ok, but I don't think you'll like it
```


```
“Sorry, did I say something wrong?" said Marvin, dragging himself on
regardless. "Pardon me for breathing, which I never do anyway so I don't know why I bother to say it, oh God I'm so depressed. Here's another one of those self-satisfied doors. Life! Don't talk to me about life.” 
```


# Zabbix


!downtime hostname 5 minutes disk swap


REST + Mojolicious::UserAgent == <3


# SOAP

* SOAD?


# LDAP


authentication


Atlassian Stash


# Web Hooks


* Ansible
* Rundeck API
# Automated Deployments


```
package Marvin::Plugin::Rundeck;

use base 'Mojolicious::Plugin';
use experimental 'signatures';

sub register($self, $app, $config) {
  ...
} 


```
package Marvin::Plugin::Rundeck;

use base 'Mojolicious::Plugin';
use experimental 'signatures';

sub register($self, $app, $config) {
  $app->routes->post('/web-hook' => \&web_hook);

} 

sub web_hook($self) { ... }
```


```
public '!hello :world' => sub { ... };
private '*direct' => sub { ... }; 
```


Cleverbot


* Online AI
* 59.3 %


PLS HELP MAKE THE AI SAD


```
$ cpanm Marvin
````

github.com/marcusramberg/marvin


```
$ mojo genere mavin bae
  [mkdir] /Users/marcus/Source/marvin/bae
  [write] /Users/marcus/Source/marvin/bae/marvin.pl
  [exist] /Users/marcus/Source/marvin/bae
  [write] /Users/marcus/Source/marvin/bae/marvin.conf
  [exist] /Users/marcus/Source/marvin/bae
  [write] /Users/marcus/Source/marvin/bae/cpanfile
  [mkdir] /Users/marcus/Source/marvin/bae/log
  [mkdir] /Users/marcus/Source/marvin/bae/lib
```

```
vi marvin.development.conf
```


```
{
  adapters => [
    {
      type    => 'XMPP',
      user    => 'user@jabber.mycompany.com',
      pass    => app->password,
      host    => 'jabber.mycompany.com',
      nick    => 'marvin',
      rooms   => ['chatops@conference.jabber.mycompany.com'],
      tagline => 'Oh god I am so depressed.',
    },
  ],
```


# FINALLY


# QUESTIONS
