
function Spawn(template, location, rotation) {
	self.__KeyValueFromString("EntityTemplate", template);
	self.SpawnEntityAtLocation(location, rotation);
}
