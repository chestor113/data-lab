#!/bin/bash
ssh-keygen -R 89.169.130.218
ssh-keygen -R 10.10.20.11
ssh-keygen -R 10.10.20.12
ssh-keygen -R 10.10.20.13

ssh-keygen -R lb01
ssh-keygen -R kafka01
ssh-keygen -R kafka02
ssh-keygen -R kafka03

echo "Kafka SSH host keys flushed"