local Catalog = {}
Catalog.Personalities = {"Friendly", "Serious", "Mysterious", "Funny"}
Catalog.Tabs = {"Costume", "Top", "Bottom", "Hat", "Shoes", "Critter"}
Catalog.SelectionCooldown = 0.5
Catalog.Items = {
	Costume = {{id="none",name="No costume"},{id="desert_bird",name="Desert bird costume",locked=true}},
	Top = {{id="western_shirt",name="Weathered western shirt"}},
	Bottom = {{id="ragged_jeans",name="Ragged denim"}},
	Hat = {{id="none",name="No hat"},{id="cowboy",name="Cowboy hat"}},
	Shoes = {{id="brown_boots",name="Brown boots"}},
	Critter = {{id="none",name="No companion"},{id="dog",name="Dog · unlock through Story Mode",locked=true}},
}
function Catalog.defaultOutfit()
	return {Costume="none",Top="western_shirt",Bottom="ragged_jeans",Hat="cowboy",Shoes="brown_boots",Critter="none"}
end
function Catalog.find(slot,id)
	for _,item in Catalog.Items[slot] or {} do if item.id==id then return item end end
	return nil
end
function Catalog.validateIdentity(name,gender,personality)
	if type(name)~="string" then return false,"Enter a character name." end
	local clean=name:match("^%s*(.-)%s*$")
	local length=utf8.len(clean)
	if not length or length<2 or length>24 or clean:find("%c") then return false,"Use a name between 2 and 24 characters." end
	if gender~="Boy" and gender~="Girl" then return false,"Choose Boy or Girl." end
	if not table.find(Catalog.Personalities,personality) then return false,"Choose a personality." end
	return true,clean
end
function Catalog.canEquip(outfit,slot,id)
	if type(slot)~="string" or type(id)~="string" then return false,"Invalid item." end
	local item=Catalog.find(slot,id)
	if not item then return false,"That item does not exist." end
	if item.locked then return false,"Unlock this item through Story Mode." end
	if slot~="Costume" and outfit.Costume~="none" then return false,"Remove your costume to change individual clothing." end
	return true
end
return Catalog
