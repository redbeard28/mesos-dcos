#!/bin/bash
  # Example ip-detect script using an external authority
  # Uses the AWS compatible Packet Metadata Service to get the nodes internal
  # ipv4 address
  echo $(curl -fsSL https://metadata.packet.net/2009-04-04/meta-data/local-ipv4)
