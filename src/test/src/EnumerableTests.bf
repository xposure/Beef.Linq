using System.Collections;
using System;
namespace Beef.Linq
{
	public class EnumerableTests
	{
		[Test]
		public static void Select()
		{
			let data = scope List<(int x, int y, float z, float w)>();
			data.Add((1, 2, 3, 4));
			data.Add((4, 3, 2, 1));

			let actual = data.Select(scope (it) => (x: it.x, y: it.y)).ToList(.. scope .());

			let expected = scope List<(int x, int y)>();
			expected.Add((1, 2));
			expected.Add((4, 3));

			Test.Assert(actual.Count == 2);
			Test.Assert(actual.SequenceEquals(expected));
		}

		[Test]
		public static void Where()
		{
			let data = scope List<(int x, int y, float z, float w)>();
			data.Add((1, 2, 3, 4));
			data.Add((4, 3, 2, 1));

			let actual = data.Where(scope (it) => it.x == 1).ToList(.. scope .());

			Test.Assert(actual.Count == 1);
			Test.Assert(actual[0] == (1, 2, 3, 4));
		}

		[Test]
		public static void Take()
		{
			let data = scope List<int>();
			for(var i < 20)data.Add(i);
			
			let actual = data.Take(10).ToList(.. scope .());

			let expected = scope List<int>();
			for(var i < 10)expected.Add(i);

			Test.Assert(actual.Count == 10);
			Test.Assert(actual.SequenceEquals(expected)  == true);
		}

		[Test]
		public static void Skip()
		{
			let data = scope List<int>();
			for(var i < 20)data.Add(i);
			
			let actual = data.Skip(10).ToList(.. scope .());

			let expected = scope List<int>();
			for(var i < 10)expected.Add(i + 10);

			Test.Assert(actual.Count == 10);
			Test.Assert(actual.SequenceEquals(expected)  == true);
		}

		[Test]
		public static void Range()
		{
			{
				let actual = Enumerable.Range(10).ToList(.. scope .());
				let expected = scope List<int>();
				for(var i < 10)expected.Add(i);
				Test.Assert(actual.SequenceEquals(expected) == true);
			}

			{
				let actual = Enumerable.Range(10, 20).ToList(.. scope .());
				let expected = scope List<int>();
				for(var i < 10)expected.Add(i + 10);
				Test.Assert(actual.SequenceEquals(expected) == true);
			}
		}


		[Test]
		public static void Sum(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(2);
			data.Add(3);
			data.Add(4);

			let actual = data.Sum();
			Test.Assert(actual == 10);
		}

		[Test]
		public static void SumWithSelect()
		{
			let data = scope List<(float z, float w)>();
			data.Add(( 3.1f, 4.4f));
			data.Add(( 5.4f, 9.4f));

			let actual = data.Sum((it) => it.z);
			Test.Assert(actual == 3.1f + 5.4f);
		}

		[Test]
		public static void Avg(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(1);
			data.Add(2);
			data.Add(2);
			data.Add(4);

			let actual = data.Avg();

			Test.Assert(actual == 2);
		}

		[Test]
		public static void AvgWithSelect()
		{
			let data = scope List<(float z, float w)>();
			data.Add(( 3.1f, 4.4f));
			data.Add(( 5.4f, 9.7f));
			data.Add(( 2.7f, 2.6f));
			data.Add(( 4.8f, 3.1f));

			let actual = data.Avg((it) => it.z);
			Test.Assert(actual == (3.1f + 5.4f + 2.7f + 4.8f) / 4f);
		}

		[Test]
		public static void Count(){
			let data = scope List<int>();
			for(var i < 100)
				data.Add(i);

			let actual = data.Count();

			Test.Assert(actual == 100);
		}
	}
}
