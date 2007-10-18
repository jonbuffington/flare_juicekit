package flare.tests
{
	import flare.query.Arithmetic;
	import flare.query.Comparison;
	import flare.query.And;
	import flare.query.Or;
	import flare.query.Variable;
	import flare.query.If;
	import flare.query.Range;
	import flare.query.Literal;
	import flare.query.Expression;
	import unitest.TestCase;

	public class ExpressionTests extends TestCase
	{
		public function ExpressionTests() {
			addTest("testExpressions");
		}
		
		public function testExpressions():void 
		{
			var t1:Date = new Date(1979,5,15);
			var t2:Date = new Date(1982,2,19);
			
			var l:Variable = new Variable("a");
			var r:Variable = new Variable("b");
			
			var lt:Expression   = Comparison.LessThan(l,r);
			var gt:Expression   = Comparison.GreaterThan(l,r);
			var eq:Expression   = Comparison.Equal(l,r);
			var neq:Expression  = Comparison.NotEqual(l,r);
			var lteq:Expression = Comparison.LessThanOrEqual(l,r);
			var gteq:Expression = Comparison.GreaterThanOrEqual(l,r);
			
			var add:Expression = Arithmetic.Add(l, r);
			var sub:Expression = Arithmetic.Subtract(l, r);
			var mul:Expression = Arithmetic.Multiply(l, r);
			var div:Expression = Arithmetic.Divide(l, r);
			var mod:Expression = Arithmetic.Mod(l, r);
			
			var and:Expression  = new And(Comparison.GreaterThan(mul, add),
										  Comparison.GreaterThan(add, sub));
			var or:Expression   = new Or(Comparison.GreaterThan(add, mul),
									      Comparison.GreaterThan(mul, add));
			
			var iff:Expression = new If(eq, add, sub);
			
			var range:Range = new Range(new Literal(-1), new Literal(+1), l);
			var span:Range  = new Range(new Literal(t1), new Literal(t2), l);
			
			var tests:Array = [
				// numbers
				{expr:lt,   input:{a:0,b:0}, result:false},
				{expr:gt,   input:{a:0,b:0}, result:false},
				{expr:eq,   input:{a:0,b:0}, result:true},
				{expr:neq,  input:{a:0,b:0}, result:false},
				{expr:lteq, input:{a:0,b:0}, result:true},
				{expr:gteq, input:{a:0,b:0}, result:true},
				{expr:lt,   input:{a:1,b:0}, result:false},
				{expr:gt,   input:{a:1,b:0}, result:true},
				{expr:eq,   input:{a:1,b:0}, result:false},
				{expr:neq,  input:{a:1,b:0}, result:true},
				{expr:lteq, input:{a:1,b:0}, result:false},
				{expr:gteq, input:{a:1,b:0}, result:true},
				{expr:lt,   input:{a:0,b:1}, result:true},
				{expr:gt,   input:{a:0,b:1}, result:false},
				{expr:eq,   input:{a:0,b:1}, result:false},
				{expr:neq,  input:{a:0,b:1}, result:true},
				{expr:lteq, input:{a:0,b:1}, result:true},
				{expr:gteq, input:{a:0,b:1}, result:false},
				
				{expr:add,  input:{a:2,b:3}, result:5},
				{expr:sub,  input:{a:2,b:3}, result:-1},
				{expr:mul,  input:{a:2,b:3}, result:6},
				{expr:div,  input:{a:2,b:3}, result:2/3},
				{expr:mod,  input:{a:2,b:3}, result:2},
				{expr:add,  input:{a:3,b:2}, result:5},
				{expr:sub,  input:{a:3,b:2}, result:1},
				{expr:mul,  input:{a:3,b:2}, result:6},
				{expr:div,  input:{a:3,b:2}, result:1.5},
				{expr:mod,  input:{a:3,b:2}, result:1},
				
				{expr:and,  input:{a:3,b:2}, result:true},
				{expr:and,  input:{a:0,b:2}, result:false},
				{expr:or,   input:{a:3,b:2}, result:true},
				{expr:or,   input:{a:0,b:0}, result:false},
				
				{expr:iff,  input:{a:2,b:3}, result:-1},
				{expr:iff,  input:{a:3,b:3}, result:6},
				
				{expr:range,input:{a:-2},    result:false},
				{expr:range,input:{a:-1},    result:true},
				{expr:range,input:{a:0},     result:true},
				{expr:range,input:{a:1},     result:true},
				{expr:range,input:{a:2},     result:false},
				
				// dates
				{expr:lt,   input:{a:t1,b:t2}, result:true},
				{expr:gt,   input:{a:t1,b:t2}, result:false},
				{expr:eq,   input:{a:t1,b:t2}, result:false},
				{expr:neq,  input:{a:t1,b:t2}, result:true},
				{expr:lteq, input:{a:t1,b:t2}, result:true},
				{expr:gteq, input:{a:t1,b:t2}, result:false},	
				{expr:lt,   input:{a:t1,b:t1}, result:false},
				{expr:gt,   input:{a:t1,b:t1}, result:false},
				{expr:eq,   input:{a:t1,b:t1}, result:true},
				{expr:neq,  input:{a:t1,b:t1}, result:false},
				{expr:lteq, input:{a:t1,b:t1}, result:true},
				{expr:gteq, input:{a:t1,b:t1}, result:true},
				{expr:span, input:{a:new Date(1978,1)}, result:false},
				{expr:span, input:{a:t1},               result:true},
				{expr:span, input:{a:new Date(1980,1)}, result:true},
				{expr:span, input:{a:t2},               result:true},
				{expr:span, input:{a:new Date(1990,1)}, result:false},
				
				// strings
				{expr:lt,   input:{a:"a",b:"b"}, result:true},
				{expr:gt,   input:{a:"a",b:"b"}, result:false},
				{expr:eq,   input:{a:"a",b:"b"}, result:false},
				{expr:neq,  input:{a:"a",b:"b"}, result:true},
				{expr:lteq, input:{a:"a",b:"b"}, result:true},
				{expr:gteq, input:{a:"a",b:"b"}, result:false},	
				{expr:lt,   input:{a:"a",b:"a"}, result:false},
				{expr:gt,   input:{a:"a",b:"a"}, result:false},
				{expr:eq,   input:{a:"a",b:"a"}, result:true},
				{expr:neq,  input:{a:"a",b:"a"}, result:false},
				{expr:lteq, input:{a:"a",b:"a"}, result:true},
				{expr:gteq, input:{a:"a",b:"a"}, result:true},
			];

			for (var i:uint=0; i<tests.length; ++i) {
				var e:Expression = tests[i].expr;
				var val:Object = e.eval(tests[i].input);
				assertEquals(tests[i].result, val, i+":"+e.toString());
			}
		}
	}
}