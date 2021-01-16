using System.Collections;
using System;
namespace Beef.Linq
{
	public class EnumerableTests
	{
		public struct TestData : this(int x, int y, float z, float w){}

		[Test]
		public static void Select()
		{
			var data = scope List<(int x, int y, float z, float w)>();
			data.Add((1, 2, 3, 4));
			data.Add((4, 3, 2, 1));

			var linq = data
						.Select(scope (it) => (x: it.x, y: it.y), scope (it) => it.GetEnumerator())
						.Select(scope (it2) => it2.x, scope (it2) => it2.GetEnumerator());

			var count = 0;
			for(var it in linq)
				count++;

			Test.Assert(count == 2);
		}

		[Test]
		public static void Sum(){
			var data = scope List<int>();
			data.Add(1);
			data.Add(2);
			data.Add(3);
			data.Add(4);

			Test.Assert(data.Sum() == 10);
		}

		[Test]
		public static void SumWithSelect()
		{
			var data = scope List<(float z, float w)>();
			data.Add(( 3.1f, 4.4f));
			data.Add(( 5.4f, 9.4f));

			Test.Assert(data.Sum((it) => it.z) == 3.1f + 5.4f);
		}

		[Test]
		public static void Avg(){
			var data = scope List<int>();
			data.Add(1);
			data.Add(1);
			data.Add(2);
			data.Add(2);
			data.Add(4);

			Test.Assert(data.Avg() == 2);
		}

		[Test]
		public static void AvgWithSelect()
		{
			var data = scope List<(float z, float w)>();
			data.Add(( 3.1f, 4.4f));
			data.Add(( 5.4f, 9.7f));
			data.Add(( 2.7f, 2.6f));
			data.Add(( 4.8f, 3.1f));

			let r = data.Avg((it) => it.z);
			Test.Assert(r == (3.1f + 5.4f + 2.7f + 4.8f) / 4f);
		}

		[Test]
		public static void Count2(){
			var data = scope List<(float z, float w)>();
			data.Add(( 3.1f, 4.4f));
			data.Add(( 5.4f, 9.4f));

			Test.Assert(data.Count2() == 2);
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
