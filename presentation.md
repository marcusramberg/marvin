# Marvin

Hi, and welcome to this talk. My name is Marcus Ramberg, you might know me from such Perl projects as Catalyst and Mojolicious. I've been an open source hacker and contributor for the past 15 years or so.  I even have a blog...

I've always dabbled in operations, but recently I've taken a full time ops position here at the university of Oslo, managing about 2000 domains running various web pages and applications for the university on a diverse platform spanning about 150 servers.

For the last 5 years before I started at the university, I ran a small startup called Nordaaker. We were often working geographically separated, and to keep track of the teamwork we used Slack.

Slack is a very nice real time chat system. One of the features we used a lot were hooks into the other systems like GitHub and our continuous build system. This allowed us to work in public, so that everybody knew what was going on, without having too much time wasted on meetings and coordination.

At Nordaaker I was the only ops person, but for the last 6 months I've been  working in an operations team, and the need to coordinate on operations is even greater than before. UiO primarily use Jabber as their real time chat system, which works in a similar way to Slack. I missed a lot of the automation tho, so I started looking into a setting up a channel bot to implement something similar to what we had in Nordaaker.

I looked into both Hubot, which I've used before and Lita, but even tho I'm familiar with both Ruby and JavaScript, I found them cumbersome to customize to our environment. However I already had some experience writing IRC clients, because I recently helped to build Convos - convos.by - a web socket based persistent IRC Client. I also have a wasted youth running offer bots on efnet.

I figured writing a bot framework wasn't so different from writing a chat client. Convos is built using the Mojolicious framework, which I help maintain, so it seemed like a natural choice for my bot framework as well.

Mojolicious is a wonderful toolkit, and probably the main reason why I still develop in Perl5. It's a complete MVC Web framework, but it is also a Real Time IOLoop, as well as a fully featured HTTP stack, with tools like JSON Pointers, an ASync User Agent and a full XML DOM Parser. It integrates with the AnyEvent Perl modules through libev, which makes it easy to hook various communication protocol straight into the IOLoop.

If you didn't understand all of that, suffice to say it's a lot like node.js, but with all the parts included in the box. This helps rememedy the Paradox of choice. You already have a sane default.

I decided to write a simple bot framework, but because I'm pretty lazy, I built it as a thin layer on top of Mojolicious::Lite. I'm reusing the entire infrastructure, including the daemon and the http serving. This makes it trivial to create things like web hooks, or custom HTTP requests, as well as processing of backend responses.

I am using the routing system from Mojolicious for chat commands, by simply rewriting the messages to use slashes instead of spaces before doing the route dispatch. This means that Marvin has a powerful mechanism for matching channel messages. You can use the same place holder as in traditional web routes.

In addition, I've created an Adapter system to allow Marvin to simply talk to external chat system. For the initial release we support IRC And XMPP, but it's fairly trivial to write your own. The adapters use the Event Emitter mechanism in Mojo. This makes them loosely coupled to the rest of the bot.

I'm also reusing the Plugin system, which makes it trivial to extend Marvin with your own commands and hooks. We're going to look into building your own plugins a little later.

Of course, the first thing I had to do was find a name for my new project. Seeing as I'm a hoppy frood who really knows where my towel is, there was only ever one bot for me...

Marvin, the depressed android from Hitchhiker's Guide To The Galaxy. Somehow a depressive bot seems to go very well together with operations. Just like that bottle of scotch in your drawer.

The first real plugin I wrote integrates with RT, our trouble ticketing system. It polls our main queue and announces new tickets as soon as they come in. I'm actually planning on redoing this part using a Scrip that triggers a web hook on ticket creation, to reduce system consumption and reduce delays, more about this later.

I also added a exclaim take command. The way it works in our team, one person has the main responsibility for handling new tickets for a week at a time, but sometimes our team members have better qualifications for handling a ticket, and the take command lets us track that in public, as well as keeping the history in RT.

When you name a bot Marvin, you can't just let it come up with any boring response, so whenever you take a ticket, Marvin responds with something like 'I think you ought to know I'm feeling very depressed', or 'Yes master, I live to serve you. Well, I don't actually live...'. On my ever growing TODO is making this into a response system so you can customize the generic responses to add your own unique personality to your bots.

UiO has recently implemented Zabbix as their main monitoring tool, and we also get alarms posted directly in Jabber. This is useful, but can be noisy when we are trying to do actual maintenance, so I've implemented a Zabbix plugin to create server maintenance windows as well:

 exclaim downtime zaphod 5 minutes disk swap will squelsh alterts for zaphod for the next 5 minutes and log "disk swap" to zabbix. Of course, you can't escape the bitter ack from marvin.

Even though there are CPAN modules for both RT and Zabbix, I found it trivial to just implement these using the REST APIs directly. If you prefer, you can just as easily just use any cpan module in your plugins tho. I just find it's important to find a balance between the cost of using an external module versus the cost of implementing the functionality directly.

This balance depends on the complexity of the task. If you have to integrate with a SOAP API, I recommend running away, I mean I recommend using a module.

For our use case, it's great that Jabber is authenticated, because I can trust that the user name from the Jabber server is authenticated in our central LDAP directory.

That means nobody can spoof a user and run a command as someone else. Of course this is not the case for the IRC adapter, so I eventually plan on implementing an in-bot authentication mechanism as well.

For our Git hosting, we use Atlassian Stash. I've written a simple Stash plugin which accepts a list of git repos and maps them to rooms. This is using the built in Mojolicious web server to accept web hook calls from a Stash plugin. Webhooks aren't supported directly in Stash, but Atlassian provides a free plugin.

Using web hooks is very simple, and because of the push model, it means your alerts are instant. It's very common for ops teams to depend on cron jobs that poll a service on a regular interval, but this can make the services very frustrating to work with. As long as you restrict access on a IP-level, the simplicity of a web hook means that is a fairly secure way to trigger jobs without the delays.

In fact I'm currently working on a variant of this pattern to trigger Ansible jobs on our server infrastructure, via the Rundeck API. This means we can trigger deployments directly from the chat room in response to RT tickets.

Let's look at the beginning of this work as an example of how you can write your own integrations into Marvin. As I mentioned earlier, we are using the Mojolicious Plugin mechanism, so the base template for a new plugin is exactly the same.

A web hook also uses the Mojolicious router, and emits messages for the adapter to send to the designated rooms.

If you want to handle a public command, you use a public route. private routes would trigger on messages directly addressed to the bot in rooms, as well as private messages.

Of course, a channel bot can't be all work and no play, or it will be a pretty
dull boy. I haven't had time to add animated gif searches and cute kittens lie the hubot people yet, but to give a decent base line, I've added a Cleverbot plugin.

This online AI talks to people on the internet, and learns to get better at pretending to be a human all the time. It recently scored 59.3% in a Turing test, and quite frankly it can be good company sometimes on lonely maintenance missions.

My only real problem with Cleverbot so far is that it seems a bit too happy. If someone can help me making it more depressed, I would be very thankful.

Ok, so now that I've shown you some of the things that you can do with Mojo, it's time to look into installing it.

Soon, you will be able to install Marvin directly from CPAN or you can get the latest commit straight from github. (cpanm accepts github urls as well, if you're not using cpanm to install your Perl modules, you are probably doing it wrong).

After that you should generate your own bot using mojo generate marvin nick, where nick is the name of your bot. This will create a folder using your bot name, a default marvin.conf and marvin.pl for you to extend, as well as a lib folder. if you want marvin to log to file, just add a 'log' folder as well.

I recommend using a .development. file to track your local config. any section you add here will override the main marvin.conf You can have as many adapters as you like running in the ioloop. If you don't want to save your password in the config file, you can get marvin to prompt you for it on startup as demonstrated here.

Finally you can just start the script by running ./marvin daemon -- It accepts the same arguments as a normal mojo app, so you can add --listen for instance for listen to a specified port/adddress. At this point, if you've done it right marvin should be connecting to your chat server. While debugging, it can be useful to know that all the normal MOJO ENV debugging tricks work, like MOJO_USERAGENT_DEBUG=1 and MOJO_SERVER_DEBUG=1 and MOJO_IRC_DEBUG=1.

As you can tell from this presentation, there is still a lot of work to be done on Marvin. However, I believe I've now reached a level where it's useful for other people. To this effect, I'm releasing the 0.1 version of Marvin to CPAN early next week. If you're impatient, you can already check it out from my git repo at github.com/marcusramberg/marvin/


It looks like we have time for questions?
