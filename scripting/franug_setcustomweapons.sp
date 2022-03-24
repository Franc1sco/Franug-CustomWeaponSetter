/*  SM FPVMI - Custom Weapons Setter
 *
 *  Copyright (C) 2022 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>
#include <fpvm_interface>
#pragma newdecls required

#define DATA "0.1"

char sConfig[PLATFORM_MAX_PATH];
Handle kv;

public Plugin myinfo =
{
	name = "SM FPVMI - Custom Weapons Setter",
	author = "Franc1sco franug",
	description = "",
	version = DATA,
	url = "http://steamcommunity.com/id/franug"
}

public void OnMapStart()
{
	RefreshKV();
	Downloads();	
}

public void RefreshKV()
{
	BuildPath(Path_SM, sConfig, PLATFORM_MAX_PATH, "configs/franug_customweaponsetter/configuration.txt");
	
	if(kv != INVALID_HANDLE) CloseHandle(kv);
	
	kv = CreateKeyValues("CustomModels");
	FileToKeyValues(kv, sConfig);
}

void Downloads()
{
	char imFile[PLATFORM_MAX_PATH];
	char line[192];
	
	BuildPath(Path_SM, imFile, sizeof(imFile), "configs/franug_customweaponsetter/downloads.txt");
	
	Handle file = OpenFile(imFile, "r");
	
	if(file != INVALID_HANDLE)
	{
		while (!IsEndOfFile(file))
		{
			if (!ReadFileLine(file, line, sizeof(line)))
			{
				break;
			}
			
			TrimString(line);
			if( strlen(line) > 0 && FileExists(line))
			{
				AddFileToDownloadsTable(line);
			}
		}

		CloseHandle(file);
	}
	else
	{
		LogError("[SM] no file found for downloads (configs/franug_customweaponsetter/downloads.txt)");
	}
}

public void OnClientPostAdminCheck(int client)
{
	setWeapons(client);
}

void setWeapons(int client)
{
	char weapon[128], view[PLATFORM_MAX_PATH], drop[PLATFORM_MAX_PATH], world[PLATFORM_MAX_PATH];
	if(KvGotoFirstSubKey(kv))
	{
		do
		{
			KvGetSectionName(kv, weapon, sizeof(weapon));
			KvGetString(kv, "view", view, PLATFORM_MAX_PATH, "none");
			KvGetString(kv, "world", world, PLATFORM_MAX_PATH, "none");
			KvGetString(kv, "drop", drop, PLATFORM_MAX_PATH, "none");
			
			FPVMI_SetClientModel(client, weapon, !StrEqual(view, "none")?PrecacheModel(view):-1, !StrEqual(world, "none")?PrecacheModel(world):-1, drop);
			
		} while (KvGotoNextKey(kv));
	}
	KvRewind(kv);
}
