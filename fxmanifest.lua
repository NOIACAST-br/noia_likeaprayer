fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'NOIACAST'
description 'Noia Like a Prayer - Supernatural script for RedM'
version '1.0.0'
lua54 'yes'
shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

escrow_ignore {
	'config.lua'
}

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependency '/assetpacks'