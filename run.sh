#!/bin/sh

MINETEST_VERSION=5.0.1
# IMAGE=webd97/minetestserver:${MINETEST_VERSION}  			
IMAGE=metacoma/9mine:latest

docker run --rm --name mine9 																		  \
	-it 																														\
	-p 0.0.0.0:30000:30000/udp 																			\
 	-v `pwd`/9mine_game:/usr/local/games/9mine	  	  							\
	-v `pwd`/9mine_game/minetest.conf:/usr/local/etc/minetest.conf 	\
	-v `pwd`/mods:/usr/local/mods																		\
	-v `pwd`/inventory.yml:/tmp/inventory.yml												\
  -v `pwd`/pprint.lua:/usr/local/share/lua/5.1/pprint.lua					\
	${IMAGE}																												\
	--config /usr/local/etc/minetest.conf														\
	--gameid 9mine 																			

#	-v `pwd`/worlds:/usr/local/worlds										\
#--verbose																						\
#--info   																						\
