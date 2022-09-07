# syntax=docker/dockerfile:1
FROM ubuntu:focal
RUN apt update && apt upgrade --yes && apt update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt install --yes python3 python3-pip python-is-python3 git wget tar 
RUN echo conan_builder > /etc/hostname

#install cmake 2.24.1
RUN wget -q https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-linux-x86_64.tar.gz
RUN tar -xf cmake-3.24.1-linux-x86_64.tar.gz
RUN cp -R cmake-3.24.1-linux-x86_64/* /usr
RUN rm -rf cmake-3.24.1-linux-x86_64* 

# Set the locale
RUN apt-get -y install locales
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8
ENV DOCKER_HOSTNAME=${DOCKER_HOSTNAME:-conan_builder}

RUN mkdir /work
RUN useradd -ms /bin/bash msp
USER msp
WORKDIR /work
ENV PATH="${PATH}:/home/msp/.local/bin"

USER root
RUN wget -q https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/gcc-arm-10.3-2021.07-x86_64-arm-none-eabi.tar.xz
RUN tar -xf gcc-arm-10.3-2021.07-x86_64-arm-none-eabi.tar.xz --directory /opt/
RUN rm gcc-arm-10.3-2021.07-x86_64-arm-none-eabi.tar.xz

USER msp
RUN pip install conan --user
RUN conan profile new default --detect
RUN rm /home/msp/.conan/profiles/default
ADD gcc-arm-none-eabi.conan /home/msp/.conan/profiles/default
ADD gcc-arm-none-eabi.cmake /opt/gcc-arm-none-eabi.cmake
ADD gcc-arm-none-eabi.env /opt/gcc-arm-none-eabi.env
RUN ["/bin/bash", "-c", "echo '. /opt/gcc-arm-none-eabi.env' >> /home/msp/.bashrc"]
