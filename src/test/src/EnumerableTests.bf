using System.Collections;
using System;
namespace System.Linq
{
	public class EnumerableTests
	{
		[Test]
		public static void Any()
		{
			let data = scope List<int>();

			var actual = data.Any();
			Test.Assert(!actual);

			actual = data.Any((it) => it == 2);
			Test.Assert(!actual);

			data.Add(1);
			data.Add(2);
			data.Add(3);
			data.Add(4);

			 actual = data.Any((it) => it == 2);
			Test.Assert(actual);

			actual = data.Any();
			Test.Assert(actual);

			data.RemoveAt(1);
			actual = data.Any((it) => it == 2);
			Test.Assert(!actual);
		}

		[Test]
		public static void All()
		{
			let data = scope List<int>();

			var actual = data.All((it) => it == 2);
			Test.Assert(!actual);

			data.Add(2);
			data.Add(2);
			data.Add(2);
			data.Add(2);

			 actual = data.All((it) => it == 2);
			Test.Assert(actual);

			data.Add(3);
			actual = data.All((it) => it == 2);
			Test.Assert(!actual);
		}

		/*
		[Test]
		public static void Contains()
		{
			let data = scope List<int>();

			var actual = data.Contains(2);
			Test.Assert(!actual);

			data.Add(2);

			actual = data.Contains(2);
			Test.Assert(actual);

			data.InsertAt(0, 3);
			actual = data.All((it) => it == 2);
			Test.Assert(!actual);
		}
		*/

		[Test]
		public static void Average()
		{
				let data = scope List<int>();
				data.Add(1);
				data.Add(1);
				data.Add(2);
				data.Add(2);
				data.Add(4);

				let actual = data.Average();

				Test.Assert(actual == 2);
		}

		[Test]
		public static void Max()
		{
				let data = scope List<int>();
	
				var actual = data.Max();
				Test.Assert(actual == default);
	
				data.Add(3);
				actual = data.Max();
				Test.Assert(actual == 3);
	
				data.Add(1);
				actual = data.Max();
				Test.Assert(actual == 3);
		}

		[Test]
		public static void Min()
		{
				let data = scope List<int>();

				var actual = data.Min();
				Test.Assert(actual == default);

				data.Add(3);
				actual = data.Min();
				Test.Assert(actual == 3);

				data.Add(1);
				actual = data.Min();
				Test.Assert(actual == 1);

		}

		[Test]
		public static void Sum()
		{
			let data = scope List<int>();
			data.Add(1);
			data.Add(2);
			data.Add(3);
			data.Add(4);

			let actual = data.Sum();
			Test.Assert(actual == 10);

		}

		[Test]
		public static void ElementAt(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(2);
			data.Add(3);

			let actual = data.ElementAt(1);
			Test.Assert(actual == 1);
		}

		
		[Test(ShouldFail=true)]
		public static void ElementAtSequenceError()
		{
			let data = scope List<int>();
			data.Add(1);
			data.Add(2);
			data.Add(3);

			data.ElementAt(4);
		}

		[Test]
		public static void First(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(2);
			data.Add(3);

			let actual = data.First();
			Test.Assert(actual == 1);
		}

		[Test]
		public static void FirstOrDefault(){
			let data = scope List<int>();

			let actual = data.FirstOrDefault();
			Test.Assert(actual == default);
		}

		
		[Test(ShouldFail= true)]
		public static void FirstFatalOnEmpty(){
			let data = scope List<int>();

			data.First();
		}

		[Test]
		public static void Last(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(2);
			data.Add(3);

			let actual = data.Last();
			Test.Assert(actual == 3);
		}

		[Test]
		public static void LastOrDefault(){
			let data = scope List<int>();

			let actual = data.LastOrDefault();
			Test.Assert(actual == default);
		}

		[Test(ShouldFail= true)]
		public static void LastFatalOnEmpty(){
			let data = scope List<int>();

			data.Last();
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
		public static void Map()
		{
			{
				let data = scope List<int>();
				data.Add(0);
				data.Add(5);
				data.Add(10);

				let actual = data.Map(0f, 1f).ToList(.. scope .());

				let expected = scope List<float>();
				expected.Add(0f);
				expected.Add(0.5f);
				expected.Add(1f);

				Test.Assert(actual.SequenceEquals(expected));
			}

			{
				let data = scope List<int>();
				data.Add(0);
				data.Add(5);
				data.Add(10);
				
				let actual = data.Map(0, 100).ToList(.. scope .());

				let expected = scope List<int>();
				expected.Add(0);
				expected.Add(50);
				expected.Add(100);

				Test.Assert(actual.SequenceEquals(expected));
			}
		}


		[Test]
		public static void Select()
		{
			let data = scope List<(int x, int y, float z, float w)>();
			data.Add((1, 2, 3, 4));
			data.Add((4, 3, 2, 1));

			let actual = data.Select( (it) => (x: it.x, y: it.y)).ToList(.. scope .());

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

			let actual = data.Where( (it) => it.x == 1).ToList(.. scope .());

			Test.Assert(actual.Count == 1);
			Test.Assert(actual[0] == (1, 2, 3, 4));
		}

		[Test]
		public static void TakeWhile(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(1);
			data.Add(2);
			data.Add(3);

			let actual = data.TakeWhile((it) => it == 1).ToList(.. scope .());
			let expected = scope List<int>();
			expected.Add(1);
			expected.Add(1);
			Test.Assert(actual.Count == 2);
		}

		
		[Test]
		public static void SkipWhile(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(1);
			data.Add(2);
			data.Add(3);

			let actual = data.SkipWhile((it) => it == 1).ToList(.. scope .());
			let expected = scope List<int>();
			expected.Add(2);
			expected.Add(3);
			Test.Assert(actual.Count == expected.Count);
		}

		[Test]
		public static void Repeat(){
			let actual = Enumerable.Repeat(10, 10).ToList(.. scope .());
			let expected = scope List<int>();
			for(var i < 10)
				expected.Add(10);

			Test.Assert(actual.SequenceEquals(expected));
		}

		[Test]
		public static void Distinct(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(1);
			data.Add(2);
			data.Add(3);

			let actual = data.Distinct().ToList(.. scope .());
			let expected = scope List<int>();
			expected.Add(1);
			expected.Add(2);
			expected.Add(3);

			Test.Assert(actual.Count == expected.Count);
			Test.Assert(actual.SequenceEquals(expected));
		
		}

		[Test]
		public static void Reverse(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(1);
			data.Add(2);
			data.Add(3);

			let actual = data.Reverse().ToList(.. scope .());
			let expected = scope List<int>();
			expected.Add(3);
			expected.Add(2);
			expected.Add(1);
			expected.Add(1);

			Test.Assert(actual.Count == expected.Count);
			Test.Assert(actual.SequenceEquals(expected));

		}
		/*[Test]
		public static void DefaultIfEmpty(){
			
			let data = scope List<int>();
			let actual = data.DefaultIfEmpty(10).ToList(.. scope .());
			let expected = scope List<int>();
			expected.Add(10);
			Test.Assert(actual.Count == 1);
			Test.Assert(actual[0] == 10);
		}*/

#region ToXYZ methods
		/*[Test]
		public static void ToDictionary(){
			let data = scope List<(int x, float y)>();
			data.Add((1, 2f));
			data.Add((4, 3f));

			let actual = data.ToDictionary((it) => it.x, (it) => it.y, .. scope .());

			Test.Assert(actual.Count == 2);
			Test.Assert(actual.Contains((1, 2f)));
			Test.Assert(actual.Contains((4, 3f)));
		}*/

		[Test]
		public static void ToHashSet(){
			let data = scope List<int>();
			data.Add(1);
			data.Add(2);
			data.Add(2);

			let actual = data.ToHashSet(.. scope .());

			Test.Assert(actual.Count == 2);
			Test.Assert(actual.Contains(1));
			Test.Assert(actual.Contains(2));
		}
#endregion 

	}
}
