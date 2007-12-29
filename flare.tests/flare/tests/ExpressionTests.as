package flare.tests
{
	import flare.query.And;
	import flare.query.Arithmetic;
	import flare.query.Comparison;
	import flare.query.Expression;
	import flare.query.If;
	import flare.query.Literal;
	import flare.query.Or;
	import flare.query.Range;
	import flare.query.Variable;
	import flare.query.Xor;
	import flare.query.methods.add;
	import flare.query.methods.and;
	import flare.query.methods.div;
	import flare.query.methods.eq;
	import flare.query.methods.gt;
	import flare.query.methods.gte;
	import flare.query.methods.iff;
	import flare.query.methods.lt;
	import flare.query.methods.lte;
	import flare.query.methods.mod;
	import flare.query.methods.mul;
	import flare.query.methods.neq;
	import flare.query.methods.or;
	import flare.query.methods.range;
	import flare.query.methods.sub;
	import flare.query.methods.xor;
	
	import unitest.TestCase;

	public class ExpressionTests extends TestCase
	{
		public function ExpressionTests() {
			addTest("testExpressions");
			addTest("testExpressionMethods");
		}
		
		// test variables
		private var t1:Date = new Date(1979,5,15);
		private var t2:Date = new Date(1982,2,19);
		private var _lt:Expression;
		private var _gt:Expression;
		private var _eq:Expression;
		private var _neq:Expression;
		private var _lte:Expression;
		private var _gte:Expression;
		private var _add:Expression;
		private var _sub:Expression;
		private var _mul:Expression;
		private var _div:Expression;
		private var _mod:Expression;
		private var _and:Expression;
		private var _xor:Expression;
		private var _or:Expression;
		private var _if:Expression;
		private var _range:Range;
		private var _span:Range;
		
		private function _tests():Array
		{
			return [
				// numbers
				{expr:_lt,   input:{a:0,b:0}, result:false},
				{expr:_gt,   input:{a:0,b:0}, result:false},
				{expr:_eq,   input:{a:0,b:0}, result:true},
				{expr:_neq,  input:{a:0,b:0}, result:false},
				{expr:_lte,  input:{a:0,b:0}, result:true},
				{expr:_gte,  input:{a:0,b:0}, result:true},
				{expr:_lt,   input:{a:1,b:0}, result:false},
				{expr:_gt,   input:{a:1,b:0}, result:true},
				{expr:_eq,   input:{a:1,b:0}, result:false},
				{expr:_neq,  input:{a:1,b:0}, result:true},
				{expr:_lte,  input:{a:1,b:0}, result:false},
				{expr:_gte,  input:{a:1,b:0}, result:true},
				{expr:_lt,   input:{a:0,b:1}, result:true},
				{expr:_gt,   input:{a:0,b:1}, result:false},
				{expr:_eq,   input:{a:0,b:1}, result:false},
				{expr:_neq,  input:{a:0,b:1}, result:true},
				{expr:_lte,  input:{a:0,b:1}, result:true},
				{expr:_gte,  input:{a:0,b:1}, result:false},
				
				{expr:_add,  input:{a:2,b:3}, result:5},
				{expr:_sub,  input:{a:2,b:3}, result:-1},
				{expr:_mul,  input:{a:2,b:3}, result:6},
				{expr:_div,  input:{a:2,b:3}, result:2/3},
				{expr:_mod,  input:{a:2,b:3}, result:2},
				{expr:_add,  input:{a:3,b:2}, result:5},
				{expr:_sub,  input:{a:3,b:2}, result:1},
				{expr:_mul,  input:{a:3,b:2}, result:6},
				{expr:_div,  input:{a:3,b:2}, result:1.5},
				{expr:_mod,  input:{a:3,b:2}, result:1},
				
				{expr:_and,  input:{a:3,b:2}, result:true},
				{expr:_and,  input:{a:0,b:2}, result:false},
				{expr:_xor,  input:{a:3,b:2}, result:true},
				{expr:_xor,  input:{a:1,b:1}, result:true},
				{expr:_xor,  input:{a:0,b:0}, result:false},
				{expr:_or,   input:{a:3,b:2}, result:true},
				{expr:_or,   input:{a:0,b:0}, result:false},
				
				{expr:_if,   input:{a:2,b:3}, result:-1},
				{expr:_if,   input:{a:3,b:3}, result:6},
				
				{expr:_range,input:{a:-2},    result:false},
				{expr:_range,input:{a:-1},    result:true},
				{expr:_range,input:{a:0},     result:true},
				{expr:_range,input:{a:1},     result:true},
				{expr:_range,input:{a:2},     result:false},
				
				// dates
				{expr:_lt,   input:{a:t1,b:t2}, result:true},
				{expr:_gt,   input:{a:t1,b:t2}, result:false},
				{expr:_eq,   input:{a:t1,b:t2}, result:false},
				{expr:_neq,  input:{a:t1,b:t2}, result:true},
				{expr:_lte,  input:{a:t1,b:t2}, result:true},
				{expr:_gte,  input:{a:t1,b:t2}, result:false},	
				{expr:_lt,   input:{a:t1,b:t1}, result:false},
				{expr:_gt,   input:{a:t1,b:t1}, result:false},
				{expr:_eq,   input:{a:t1,b:t1}, result:true},
				{expr:_neq,  input:{a:t1,b:t1}, result:false},
				{expr:_lte,  input:{a:t1,b:t1}, result:true},
				{expr:_gte,  input:{a:t1,b:t1}, result:true},
				{expr:_span, input:{a:new Date(1978,1)}, result:false},
				{expr:_span, input:{a:t1},               result:true},
				{expr:_span, input:{a:new Date(1980,1)}, result:true},
				{expr:_span, input:{a:t2},               result:true},
				{expr:_span, input:{a:new Date(1990,1)}, result:false},
				
				// strings
				{expr:_lt,   input:{a:"a",b:"b"}, result:true},
				{expr:_gt,   input:{a:"a",b:"b"}, result:false},
				{expr:_eq,   input:{a:"a",b:"b"}, result:false},
				{expr:_neq,  input:{a:"a",b:"b"}, result:true},
				{expr:_lte,  input:{a:"a",b:"b"}, result:true},
				{expr:_gte,  input:{a:"a",b:"b"}, result:false},	
				{expr:_lt,   input:{a:"a",b:"a"}, result:false},
				{expr:_gt,   input:{a:"a",b:"a"}, result:false},
				{expr:_eq,   input:{a:"a",b:"a"}, result:true},
				{expr:_neq,  input:{a:"a",b:"a"}, result:false},
				{expr:_lte,  input:{a:"a",b:"a"}, result:true},
				{expr:_gte,  input:{a:"a",b:"a"}, result:true},
			];
		}
		
		private function _runTests():void
		{
			var tests:Array = _tests();
			for (var i:uint=0; i<tests.length; ++i) {
				var e:Expression = tests[i].expr;
				var val:Object = e.eval(tests[i].input);
				assertEquals(tests[i].result, val, i+":"+e.toString());
			}
		}
		
		public function testExpressions():void 
		{
			var l:Variable = new Variable("a");
			var r:Variable = new Variable("b");
			
			_lt  = Comparison.LessThan(l,r);
			_gt  = Comparison.GreaterThan(l,r);
			_eq  = Comparison.Equal(l,r);
			_neq = Comparison.NotEqual(l,r);
			_lte = Comparison.LessThanOrEqual(l,r);
			_gte = Comparison.GreaterThanOrEqual(l,r);
			_add = Arithmetic.Add(l, r);
			_sub = Arithmetic.Subtract(l, r);
			_mul = Arithmetic.Multiply(l, r);
			_div = Arithmetic.Divide(l, r);
			_mod = Arithmetic.Mod(l, r);
			_and = new And(Comparison.GreaterThan(_mul, _add),
						   Comparison.GreaterThan(_add, _sub));
			_xor = new Xor(Comparison.GreaterThan(_add, _mul),
						   Comparison.GreaterThan(_mul, _add));
			_or  = new Or(Comparison.GreaterThan(_add, _mul),
						  Comparison.GreaterThan(_mul, _add));
			_if = new If(_eq, _add, _sub);
			_range = new Range(new Literal(-1), new Literal(+1), l);
			_span  = new Range(new Literal(t1), new Literal(t2), l);

			_runTests();
		}
		
		public function testExpressionMethods():void 
		{
			var a:String = "[a]";
			var b:String = "[b]";
			
			_lt  = lt(a, b);
			_gt  = gt(a, b);
			_eq  = eq(a, b);
			_neq = neq(a, b);
			_lte = lte(a, b);
			_gte = gte(a, b);
			_add = add(a, b);
			_sub = sub(a, b);
			_mul = mul(a, b);
			_div = div(a, b);
			_mod = mod(a, b);
			_and = and(gt(_mul, _add), gt(_add, _sub));
			_xor = xor(gt(_add, _mul), gt(_mul, _add));	
			_or  = or(gt(_add, _mul), gt(_mul, _add));
			_if = iff(_eq, _add, _sub);
			_range = range(-1, +1, a);
			_span  = range(t1, t2, a);
			
			_runTests();
		}
		
	}
}