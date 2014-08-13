/*
	Shop API v1.1 Include file

	By Hyuna
*/


#if defined _shop_api_included
 #endinput
#endif
#define _shop_api_included

#if AMXX_VERSION_NUM >= 175
 #pragma reqlib ShopAPI
  #if !defined AMXMODX_NOAUTOLOAD
   #pragma loadlib ShopAPI
  #endif
 #else
  #pragma library ShopAPI
#endif


#define INVALID_ITEM -1
#define DONT_CHANGE -1

/**
 * Register an item to the shop.
* @param item_name	Item name
* @param cost 		Item cost
* @param access		Item access (Default - ADMIN_ALL)
* @return			Item id if success, -1 if failed (See logs if failed)
*/
// Callback structure: myCallBack(client, itemid, cost, access)
native register_item(item_name[], cost, access = ADMIN_ALL, callback[]);


/**
 * Unregister an item from the shop.
* @param itemid		Item id
* @return			1 if success, 0 if failed (See logs if failed)
* @error 			Invaild item id
*/
native unregister_item(itemid);


/**
 * Get item info
* @param itemid		Item id
* @param szName		Item name
* @param len		Item name len (0 = don't get name)
* @param &cost 		Item cost (byref)
* @param &access		Item access (byref)
* @return			1 if success, 0 if failed (See logs if failed)
* @error 			Invaild item id
*/
native get_item_info(itemid, szName[] = "", len=0, &cost, &access);

/**
 * Set item info
* @param itemid		Item id
* @param szName		Item new name ("" = Don't change)
* @param cost 		Item new cost (DONT_CHANGE = Don't change)
* @param access		Item new access (DONT_CHANGE = Don't change)
* @return			1 if success, 0 if failed (See logs if failed)
* @error 			Invaild item id
*/
native set_item_info(itemid, szName[] = "", cost = DONT_CHANGE, access = DONT_CHANGE);


/**
 * Get total item that registared
* @noparams
* @return			Total items registared
*/
native get_total_items();


/**
 * Check if the item is vaild
* @param itemid		Item id
* @return			true if valid, false if not
*/
native bool:is_item_vaild(itemid);
