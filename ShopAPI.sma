/*
	CS Shop API v1.1
	Copyright (C) 2014 Hyuna aka NorToN
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <amxmodx>
#include <cstrike>

#define INVALID_ITEM -1
#define DONT_CHANGE -1

#define VERSION "v1.1"

enum _:iData
{
	Name[64],
	Cost,
	Access,
	Callback[32],
	fwd
}

new Array:g_items;
new g_total;

public plugin_init(){
	register_plugin("Shop API",VERSION,"Hyuna");
	
	register_saycmd("shop","cmdShop");
	
	g_items = ArrayCreate(iData);
}

// itemid 0 reserved (1 > = Invaild item)
public plugin_cfg(){
	new temp[iData]; // Lets create an empty array
	
	temp[Name] = "Reserved-DontUseMeLOL";
	temp[Cost] = 0;
	temp[Access] = (1<<31);
	temp[Callback] = "DontUseMeLOL";
	temp[fwd] = 9000; // IT'S OVER 9,000!!!
	
	ArrayPushArray(g_items,temp); // And lets push it!
}

public plugin_natives(){
	register_library("ShopAPI");
	
	register_native("register_item","native_register_item",0);
	register_native("unregister_item","native_unregister_item",0);
	
	register_native("get_item_info","native_get_item_info",0);
	register_native("set_item_info","native_set_item_info",0);
	
	register_native("get_total_items","native_get_total_items",0);
	
	register_native("is_item_vaild","native_is_item_vaild",0);
}

// native register_item(item_name[], cost, access = ADMIN_ALL, callback[]);
// Callback structure: myCallBack(client, itemid, cost, access)
public native_register_item(pluginid,params){
	static temp[iData];
	
	get_string(1,temp[Name],charsmax(temp[Name]));
	
	temp[Cost] = get_param(2);
	temp[Access] = get_param(3);
	
	get_string(4,temp[Callback],charsmax(temp[Callback]));
	
	if (!temp[Name])
	{
		log_error(AMX_ERR_NATIVE,"[Shop API] Invalid item name");
		return INVALID_ITEM;
	}
	
	if (!temp[Callback])
	{
		log_error(AMX_ERR_NATIVE,"[Shop API] Invalid item callback");
		return INVALID_ITEM;
	}
	
	static fwd_temp;
	
	fwd_temp = CreateOneForward(pluginid,temp[Callback],FP_CELL,FP_CELL,FP_CELL,FP_CELL);
	
	if (!fwd_temp)
	{
		log_error(AMX_ERR_NATIVE,"[Shop API] Error creating forward");
		return INVALID_ITEM;
	}
	
	temp[fwd] = fwd_temp;
	
	ArrayPushArray(g_items,temp);
	
	return (++g_total);
}

public native_unregister_item(pluginid,params){
	static item_tmp;
	static temp[iData];
	
	item_tmp = get_param(1);
	
	if (!IsItemValid(item_tmp))
	{
		log_error(AMX_ERR_NATIVE,"[Shop API] Invalid item %d",item_tmp);
		return 0;
	}
	
	ArrayGetArray(g_items,item_tmp,temp);
	
	DestroyForward(temp[fwd]);
	
	ArrayDeleteItem(g_items,item_tmp);
	
	g_total--;
	
	return 1;
}

// native get_item_info(itemid, szName[], len=0, &cost, &access)
public native_get_item_info(pluginid,params){
	static item_tmp;
	static temp[iData];
	
	item_tmp = get_param(1);
	
	if (!IsItemValid(item_tmp))
	{
		log_error(AMX_ERR_NATIVE,"[Shop API] Invalid item %d",item_tmp);
		return 0;
	}
	
	ArrayGetArray(g_items,item_tmp,temp);
	
	static len;
	
	len = get_param(3);
	
	if (len)
		set_string(2,temp[Name],len);
	
	set_param_byref(4,temp[Cost]);
	set_param_byref(5,temp[Access]);
	
	return 1;
}

// native set_item_info(itemid, szName[], cost, access)
public native_set_item_info(pluginid,params){
	static item_tmp;
	static temp[iData],temp2[128];
	
	item_tmp = get_param(1);
	
	if (!IsItemValid(item_tmp))
	{
		log_error(AMX_ERR_NATIVE,"[Shop API] Invalid item %d",item_tmp);
		return 0;
	}
	
	ArrayGetArray(g_items,item_tmp,temp);
	
	get_string(2,temp2,charsmax(temp2));
	
	if (temp2[0])
		copy(temp[Name],charsmax(temp[Name]),temp2);
	
	static cost,access;
	
	cost = get_param(3);
	access = get_param(4);
	
	if (cost > DONT_CHANGE)
		temp[Cost] = cost;
		
	if (access > DONT_CHANGE)
		temp[Access] = access;
	
	ArraySetArray(g_items,item_tmp,temp);
	
	return 1;
}

public native_get_total_items(pluginid,params){
	return g_total;
}

public bool:native_is_item_vaild(pluginid,params){
	return IsItemValid(get_param(1));
}

public cmdShop(client){
	static shop,cb,asize;
	static temp[iData];
	
	shop = menu_create("Shop - Main Menu","mHandler");
	cb = menu_makecallback("mCallback");
	asize = ArraySize(g_items);
	
	if (asize < 2)
		return;
	
	for (new i = 1; i < asize; i++)
	{
		ArrayGetArray(g_items,i,temp);
		
		menu_additem(shop,temp[Name],.callback = cb);
	}
	
	menu_display(client,shop);
}

public mCallback(client,menu,item){
	static temp[iData];
	ArrayGetArray(g_items,(item + 1),temp);
	
	if (temp[Access] == ADMIN_ALL)
		return ITEM_ENABLED;
		
	return (get_user_flags(client) & temp[Access] ? ITEM_ENABLED:ITEM_DISABLED);
}

public mHandler(client,menu,item){
	if (item == MENU_EXIT)
		return 1;
		
	static temp[iData],ret_temp,mny;
	ArrayGetArray(g_items,(item + 1),temp);
	
	mny = cs_get_user_money(client);
	
	if (mny < temp[Cost])
	{
		client_print(client,print_center,"#Cstrike_TitlesTXT_Not_Enough_Money");
		cs_set_user_money(client,mny,1);
		cmdShop(client);
		return 1;
	}
	
	cs_set_user_money(client,mny - temp[Cost],1);
	
	ExecuteForward(temp[fwd],ret_temp,client,(item + 1),temp[Cost],temp[Access]);
	
	return 1;
}

stock bool:IsItemValid(itemid){
	if (itemid < 1 || itemid > (ArraySize(g_items) - 1))
		return false;
		
	return true;
}

stock register_saycmd(const say_cmd[], const function[], flags = -1, const info[] = "", FlagManager = -1){
	static const saycmd[2][] = { "say", "say_team" };
	static const chars[3][1] = { '.','!','/' };
	  
	static some[128];
 
	for (new i; i < 2; i++)
	{
		for(new j; j < 4; j++)
		{
			formatex(some,128,"%s %s%s",saycmd[i],chars[j],say_cmd);
			register_clcmd(some,function,flags,info,FlagManager);
		}
	}
}
