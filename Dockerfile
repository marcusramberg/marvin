FROM sidetracked/docker-perl
MAINTAINER marcusramberg@gmail.com
RUN apk-install alpine-sdk libev-dev
ADD . /source
RUN PERL_MM_USE_DEFAULT=1 cpan App::cpanminus
WORKDIR /source
RUN perl Makefile.PL -y
RUN cpanm --no-wget --installdeps .
