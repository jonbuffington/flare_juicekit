package flare.data.converters
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flare.data.DataSchema;
	import com.adobe.serialization.json.JSON;
	import flash.utils.ByteArray;
	import flare.data.DataField;
	import flare.data.DataUtil;
	import flare.util.Property;

	/**
	 * Converts data between JSON (JavaScript Object Notation) strings and
	 * arrays of ActionScript objects.
	 */
	public class JSONConverter implements IDataConverter
	{
		/**
		 * @inheritDoc
		 */
		public function read(input:IDataInput, schema:DataSchema=null, data:Array=null):Array
		{
			return parse(input.readUTFBytes(input.bytesAvailable), schema, data);
		}
		
		/**
		 * Converts data from a JSON string into ActionScript objects.
		 * @param input the loaded input data
		 * @param schema a data schema describing the structure of the data.
		 *  Schemas are optional in many but not all cases.
		 * @param data an array in which to write the converted data objects.
		 *  If this value is null, a new array will be created.
		 * @return an array of converted data objects. If the <code>data</code>
		 *  argument is non-null, it is returned.
		 */
		public function parse(text:String, schema:DataSchema, data:Array=null):Array
		{
			var json:Object = JSON.decode(text) as Object;
			var list:Array = json as Array;
			
			if (schema != null) {
				if (schema.dataRoot) {
					// if nested, extract data array
					list = Property.$(schema.dataRoot).getValue(json);
				}
				// convert value types according to schema
				for each (var t:Object in list) {
					for each (var f:DataField in schema.fields) {
						t[f.name] = DataUtil.parseValue(t[f.name], f.type);
					}
				}
			}
			if (data != null) {
				for (var i:int=0; i<json.length; ++i)
					data.push(list[i]);
			} else {
				data = list;
			}
			return data;
		}
		
		/**
		 * @inheritDoc
		 */
		public function write(data:Array, schema:DataSchema=null, output:IDataOutput=null):IDataOutput
		{
			if (output==null) output = new ByteArray();
			output.writeUTFBytes(JSON.encode(data));
			return output;
		}
		
	} // end of class JSONCoverter
}