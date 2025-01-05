#!/bin/bash

#
# Copyright 2024  by Bastien Baranoff
#

FROM ubuntu:22.04 AS HeArTbReAkEr

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /opt/GSM/

RUN apt update
ADD mobile.cfg .
ADD openbsc.cfg .
ADD *.bin *sh .
ADD BsC* Bb* .
ADD nanobts.patch .
RUN mkdir /opt/GSM/configs_bb
RUN mkdir /opt/GSM/configs_bsc
RUN mkdir /opt/GSM/configs_VICTIM
ADD configs_VICTIM/*.h /opt/GSM/configs_VICTIM
ADD configs_bb/*.h /opt/GSM/configs_bb
ADD configs_bsc/*.h /opt/GSM/configs_bsc
RUN apt install libortp-dev autoconf autoconf libdbd-sqlite3 gcc-9 g++-9 gcc-10 g++-10 git autoconf pkg-config libtool build-essential libtalloc-dev libpcsclite-dev gnutls-dev python2 python2-dev fftw3-dev libsctp-dev libdbi-dev liburing-dev libusb-dev libusb-1.0-0-dev libmnl-dev tmux -y

RUN cp /usr/bin/python2 /usr/bin/python

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 --slave /usr/bin/g++ g++ /usr/bin/g++-10

RUN update-alternatives --set gcc /usr/bin/gcc-9

RUN git clone git://git.osmocom.org/libosmocore.git \
    && cd  libosmocore \
    && git checkout 0.9.0 \
    && autoreconf -fi \
    && ./configure \
    && make \
    && make install \
    && ldconfig

RUN git clone git://git.osmocom.org/libosmo-dsp.git \
    && cd  libosmo-dsp \
    && git checkout 1dfd800e0c8f8aad04f814dfb1445d70ec0ae947 \
    && autoreconf -fi \
    && ./configure \
    && make \
    && make install \
    && ldconfig


RUN git clone https://github.com/osmocom/osmocom-bb bb-attack
RUN mkdir -p /root/.osmocom/bb/
RUN cp /opt/GSM/mobile.cfg /root/.osmocom/bb/mobile.cfg \
    && mv Bb-2rFa.patch bb-attack \
    && cd bb-attack \
    && git checkout fc20a37cb375dac11f45b78a446237c70f00841c \
    && patch -p0 < Bb-2rFa.patch \
    && cd src \
    && cp -r /opt/GSM/configs_bb/* /opt/GSM/bb-attack/src/host/layer23/src/mobile/. \
    && rm -r /opt/GSM/configs_bb \
    && make nofirmware

RUN git clone https://github.com/osmocom/osmocom-bb bb-victim \
    && mv Bb-ViCtIm.patch bb-victim \
    && cd bb-victim \
    && git checkout fc20a37cb375dac11f45b78a446237c70f00841c \
    && patch -p0 < Bb-ViCtIm.patch \
    && cd src \
    && cp -r /opt/GSM/configs_VICTIM/* /opt/GSM/bb-victim/src/host/layer23/src/mobile/. \
    && make nofirmware

RUN cd  libosmocore \
    && git checkout 1.6.0 \
    && autoreconf -fi \
    && ./configure \
    && make \
    && make install \
    && ldconfig

RUN git clone git://git.osmocom.org/libosmo-abis.git \
    && cd  libosmo-abis \
    && git checkout 0.8.1 \
    && autoreconf -fi \
    && ./configure --disable-dahdi \
    && make \
    && make install \
    && ldconfig

RUN git clone git://git.osmocom.org/libosmo-netif.git \
    && cd  libosmo-netif \
    && git checkout 0.6.0 \
    && autoreconf -fi \
    && ./configure \
    && make \
    && make install \
    && ldconfig


RUN git clone git://git.osmocom.org/openbsc.git
RUN mv configs_bsc/* openbsc/openbsc/src/libmsc/
RUN rm -r configs_bsc
RUN mv nanobts.patch openbsc
RUN mv BsC-2rFa.patch openbsc \
    && cd openbsc \
    && git checkout master \
    && patch -p0 < BsC-2rFa.patch \
    && patch -p0 < nanobts.patch \
    && cd openbsc \
    && autoreconf -fi \
    && ./configure \
    && make \
    && make install \
    && ldconfig

RUN sed -i -e 's/sim reader/sim test/g' /root/.osmocom/bb/mobile.cfg
