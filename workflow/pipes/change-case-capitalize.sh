#!/bin/sh
ruby -ne 'print $_.split(%Q{ }).map(&:capitalize).join(%Q{ })'

