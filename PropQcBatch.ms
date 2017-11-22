--An update to the Prop Qc Helper
--now allows to batch fix props based off of a folder location that is input
--by the user


thePath = getSavePath() --will bring up the dialog path for the root path
maxFiles = getFilesRecursive thePath "*.max" --allows access into sub-folders

--loops through each max file
for i=1 to maxFiles.count do
  (
    loadMaxFile maxFiles[i]

-----------------------------make some changes here.----------------------------
	----sets the current renderer to Vray 
	renderers.current = Vray()  

    -----TURNS OFF THE ENVIRONMENT MAP (IF IT IS EVEN ON)
	useEnvironmentMap = off

	---sets the display and system units to milimeters if it is not currently set.

	if units.DisplayType != #Metric then
	
		units.DisplayType = #Metric

	if units.SystemType != #Millimeters then
		
		units.SystemType = #Millimeters

		
		-----------REMOVE SPACE IN GEO
		fn removeSpaceGeo =
		(
			select$*
			local geoName = getcurrentselection()
			max group open recursively
			for g in geoName do 
			(
				newGName = substituteString g.name " " ""
				g.name = newGName
			)
		)
	removeSpaceGeo()
	

	---REMOVE SPACE IN MATERIALS
	fn textureMaterialStuff =
		(
			bitmaptexs = getClassInstances bitMapTex
			smenmvs = sme.GetNumViews()
			for bitmapTex in bitmapTexs do
			(
				if (findstring bitmapTex.name " " != undefined) then
				(
			        newNodeName = substituteString bitMapTex.name " " ""
			        print ("Renaming node : " + bitMapTex.name + " to " + newNodename)
			        bitMapTex.name = newNodeName 
			    )
			)
			for textures in bitmapTexs do
			(
			    if( textures.filename != undefined) then
			    (
					if (findstring textures.filename " " != undefined) then
					(
			    		newTextureName = substituteString textures.filename " " ""
			    		print ("Renaming texture : " + textures.filename + " to " + newTextureName)
			    		textures.filename = newTextureName
					)
				)
			)
			for material in scenematerials do
			(
			    if (findstring material.name " " != undefined) then
			    (
			        newMName = substituteString material.name " " ""
			        print ("Renaming material : " + material.name + " to " + newMName)
			        material.name = newMName
			    )
			)
			if classof renderers.current != vray then 
			(
				renderers.current = vray()
			) 
			else 
			(
				print "File uses vray"
			)
		)
		textureMaterialStuff()

	-----RELINKS TEXTURES SO THAT 3DS MAX LOOKS FOR A FOLDER CALLED TEXTURE
	fn relinkTextureFiles =
		(
			print "-- Relinking texture files"
			bitmapNodes  = getClassInstances bitmapTex

			for t in bitmapNodes do 
			(
				if t.filename == undefined do
				( 
					continue
				)
				tFileName = filenameFromPath t.filename
				
				newPath = "texture/" + tFileName
				t.filename = newPath
				print newPath
			)
		)
		
		relinkTextureFiles()	
			
			
	-----RESETS THE MATERIAL EDITOR SO THAT THERE ARE NO RANDOM/MISSING TEXTURES/MATERIALS
			
			macros.run "Medit Tools" "clear_medit_slots"
		


	----THIS PART OF THE SCRIPT TAKES EVERYTHING IN THE SCENE, MOVES IT TO THE DEFAULT 
	----LAYER, AND DELETES ALL EMPTY LAYERS
		
	--selects all the assets in the scene
	select $*
	(
	-- Locate our target layer...
	 	local target=LayerManager.getLayerFromName "0"
	 	-- puts all ofthe selected objects in the layer specified above
	 	for node in selection do (
	  	
	  			target.addNode node
		)
	)
	--deletes all empty layers
	  for i=((layerManager.count)-1) to 0 by -1 do
	   (
	   layerobj = LayerManager.getLayer i
	   layername = layerobj.name
	   layerManager.deleteLayerByName layername
	   )
	   
	   ---deletes particle views
if objects != undefined do
(
 for o in objects do
 (
  if classof o == Particle_View do
  (
   print o.name
   delete o
  )
 )
)
 

    saveMaxFile maxFiles[i]

  )

