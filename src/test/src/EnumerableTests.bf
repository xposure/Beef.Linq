using System.Collections;
using System;
namespace Beef.Linq
{
	public class EnumerableTests
	{
		public struct TestData : this(int x, int y, float z, float w){}
		[Test]
		public static void SelectTest()
		{
			//var data = scope List<TestData>();
			var data = scope List<TestData>();
			data.Add(.(1, 2, 3, 4));
			data.Add(.(4, 3, 2, 1));

			var result1 = data.Select(scope (it) => (x: it.x, y: it.y)).ToList(.. scope List<(int x, int y)>());
			var result2 = result1.Select(scope (it) => it.x).ToList(.. scope List<int>());

			for(var it in result2)
			{
				Console.WriteLine(scope $"value: {it} ");
			}

		}

		public static void Bar()
		{
			var data = scope List<(int x, int y, float z, float w)>();
			data.Add((1, 2, 3, 4));
			data.Add((4, 3, 2, 1));

			//data.Foo(scope (it) => (x: it.x, y: it.y), scope .()); //doesn't work
			data.Foo(scope (it) => (x: it.x, y: it.y), scope List<(int x, int y)>());
		}

		public static void Foo<T, TElem, TSelector, TResult>(this T items, TSelector selector,  List<TResult> output)
			where T: concrete, IEnumerable<TElem>
			where TSelector: delegate TResult(TElem)
		{
			for(var it in items)
				output.Add(selector(it));
		}
	}
}
