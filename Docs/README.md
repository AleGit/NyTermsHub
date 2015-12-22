To build and run the the app, the command line toounit tests some data and libraries have to be installed.

Flex and Yacc
====

… are preinstalled on Macs. See `Docs/yacc` in this project for configuration details.

TPTP
====

Download the current release of the TPTP 
(*Thousands of Problems for Theorem Provers*) Library from [www.cs.miami.edu/~tptp/](http://www.cs.miami.edu/~tptp/) 
that contains problems, axiom sets, documents, and utilities. 
Unpack the archive, 
move the resulting directory to any place you like, 
and create a symbolic link `TPTP` to the directory in `/Users/Shared/`.


    
    cd /Users/Shared/
    tar -xzf ~/Downloads/TPTP-v6.3.0.tgz 
    tar -xz ~/Downloads/TPTP-v6.3.0.tar
    ln -s TPTP-v6.3.0 TPTP

Yices
=====

Download and install yices 2 for Mac OS X (64 bits) from [yices.csl.sri.com](http://yices.csl.sri.com).

See `Docs/Yices` in this project for configuration details .