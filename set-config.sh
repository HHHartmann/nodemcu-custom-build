#!/bin/bash
#
# user_config.h has a number of defines the are replaced according to their
# corresponding env X_???? variable.
#
#  Define                  Uncomment if param        Set to param   SDK3.0 ?
#  LUA_FLASH_STORE                >0                      Y           N
#  SPIFFS_FIXED_LOCATION          >0                      Y           N
#  SPIFFS_MAX_FILESYSTEM_SIZE     >0                      Y           N
#  BUILD_FATFS                  "true"                                Y
#  DEVELOP_VERSION              "true"                                Y
#  SSL_ENABLED                  "true"                                Y
#
set -e

# Only process LUA_FLASH_STORE and SPIFFS commands if SDK 2.x (no PARTITIONS defined)

if [ 0 -eq "$(grep NODEMCU_EAGLEROM_PARTITION -c user_config.h)" ] ; then

# What is carried in the following variables is the sed replacement expression.
# It makes all #defines commented by default.
declare         lfs="// #\\1"
declare spiffs_base="// #\\1"
declare spiffs_size="// #\\1"

#if env var exists and is not "0"
if [ -n "${X_LUA_FLASH_STORE}" ] && [ "${X_LUA_FLASH_STORE}" != "0" ]; then
  printf "Enabling LFS, size = %s\\n" "${X_LUA_FLASH_STORE}"
  lfs="#\\1 ${X_LUA_FLASH_STORE}"
fi

if [ -n "${X_SPIFFS_FIXED_LOCATION}" ] && [ "${X_SPIFFS_FIXED_LOCATION}" != "0" ]; then
  printf "SPIFFS location offset = %s\\n" "${X_SPIFFS_FIXED_LOCATION}"
  spiffs_base="#\\1 ${X_SPIFFS_FIXED_LOCATION}"
fi

if [ -n "${X_SPIFFS_MAX_FILESYSTEM_SIZE}" ] && [ "${X_SPIFFS_MAX_FILESYSTEM_SIZE}" != "0" ]; then
  printf "SPIFFS size = %s\\n" "${X_SPIFFS_MAX_FILESYSTEM_SIZE}"
  spiffs_size="#\\1 ${X_SPIFFS_MAX_FILESYSTEM_SIZE}"
fi
# Do sed via temp file for macOS compatability
sed -e "s!^.*\\(define *LUA_FLASH_STORE\\).*!$lfs!" \
    -e "s!^.*\\(define *SPIFFS_FIXED_LOCATION\\).*!$spiffs_base!" \
    -e "s!^.*\\(define *SPIFFS_MAX_FILESYSTEM_SIZE\\).*!$spiffs_size!" \
    user_config.h > user_config.h.new;
mv user_config.h.new user_config.h;

fi  # test for NODEMCU_EAGLEROM_PARTITION

# What is carried in the following variables is the sed replacement expression.
# It makes all #defines commented by default.
declare       fatfs="// #\\1"
declare       debug="// #\\1"
declare         ssl="// #\\1"

if [ "${X_DEBUG_ENABLED}" == "true" ]; then
  echo "Enabling debug mode"
  debug="#\\1"
fi

if [ "${X_FATFS_ENABLED}" == "true" ]; then
  echo "Enabling FatFS"
  fatfs="#\\1"
fi

if [ "${X_SSL_ENABLED}" == "true" ]; then
  echo "Enabling SSL"
  ssl="#\\1"
fi

# Do sed via temp file for macOS compatability
sed -e "s!^.*\\(define *BUILD_FATFS\\).*!$fatfs!" \
    -e "s!^.*\\(define *CLIENT_SSL_ENABLE\\).*!$ssl!" \
    -e "s!^.*\\(define *DEVELOP_VERSION\\).*!$debug!" \
    user_config.h > user_config.h.new;
mv user_config.h.new user_config.h;

