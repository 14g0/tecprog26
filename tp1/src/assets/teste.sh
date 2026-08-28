#!/bin/bash

for i in {1..15}; do make conc 1 501 502; done
for i in {1..15}; do make conc 2 501 502; done
for i in {1..15}; do make conc 4 501 502; done
for i in {1..15}; do make conc 8 501 502; done
for i in {1..15}; do make conc 1 1001 1002; done
for i in {1..15}; do make conc 2 1001 1002; done
for i in {1..15}; do make conc 4 1001 1002; done
for i in {1..15}; do make conc 8 1001 1002; done
for i in {1..15}; do make conc 1 2001 2002; done
for i in {1..15}; do make conc 2 2001 2002; done
for i in {1..15}; do make conc 4 2001 2002; done
for i in {1..15}; do make conc 8 2001 2002; done
for i in {1..15}; do make seq 501 502; done
for i in {1..15}; do make seq 1001 1002; done
for i in {1..15}; do make seq 2001 2002; done