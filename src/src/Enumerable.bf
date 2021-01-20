using System.Collections;
using System;
using internal System.Linq;

namespace System.Linq
{
	public static
	{
		public static class Enumerable
		{
			public struct RangeEnumerator<TSource> : IEnumerator<TSource>, IEnumerable<TSource>
				where TSource : operator TSource + int
			{
				TSource mCurrent;
				TSource mEnd;

				public this(TSource start, TSource end)
				{
					mCurrent = start;
					mEnd = end;
				}

				public Result<TSource> GetNext() mut
				{
					if (mCurrent == mEnd)
						return .Err;

					defer { mCurrent = mCurrent + 1; }
					return .Ok(mCurrent);
				}

				public Self GetEnumerator()
				{
					return this;
				}
			}

			public static RangeEnumerator<TSource>
				Range<TSource>(TSource count)
				where TSource : operator TSource + int
			{
				return .(default, count);
			}

			public static RangeEnumerator<TSource>
				Range<TSource>(TSource start, TSource end)
				where TSource : operator TSource + int
				where TSource : operator TSource + TSource
			{
				return .(start, end);
			}

			public struct RepeatEnumerator<TSource> : IEnumerator<TSource>, IEnumerable<TSource>
			{
				TSource mValue;
				int mCount;

				public this(TSource value, int count)
				{
					mValue = value;
					mCount = count;
				}

				public Result<TSource> GetNext() mut
				{
					if (--mCount >= 0)
						return .Ok(mValue);

					return .Err;
				}

				public Self GetEnumerator()
				{
					return this;
				}
			}

			public static RepeatEnumerator<TSource>
				Repeat<TSource>(TSource value, int count)
			{
				return .(value, count);
			}
		}


		#region Matching
		public static bool All<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): if (!predicate(val)) return false;
				case .Err: return false;
				}

				while (enumerator.GetNext() case .Ok(let val))
					if (!predicate(val))
						return false;

				return true;
			}
		}

		public static bool Any<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			for (var it in items)
				return true;

			return false;
		}

		public static bool Any<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			for (var it in items)
				if (predicate(it))
					return true;

			return false;
		}


		public static bool Contains<TCollection, TSource>(this TCollection items, TSource source)
			where TCollection : concrete, IEnumerable<TSource>
			where bool : operator TSource == TSource
		{
			var enumerator = items.GetEnumerator();
			while (enumerator.GetNext() case .Ok(let val))
				if (val == source)
					return true;

			return false;
		}


		public static bool SequenceEquals<TLeft, TRight, TSource>(this TLeft left, TRight right)
			where TLeft : concrete, IEnumerable<TSource>
			where TRight : concrete, IEnumerable<TSource>
			where bool : operator TSource == TSource
		{
			using (let iterator0 = Iterator.Wrap<TLeft, TSource>(left))
			{
				var e0 = iterator0.mEnum;
				using (let iterator1 = Iterator.Wrap<TRight, TSource>(right))
				{
					var e1 = iterator1.mEnum;

					while (true)
					{
						switch (e0.GetNext()) {
						case .Ok(let i0):
							{
								switch (e1.GetNext()) {
								case .Ok(let i1):
									{
										if (i0 != i1)
											return false;
									}
								case .Err:
									return false;
								}
							}
						case .Err:
							return e1.GetNext() case .Err;
						}
					}
				}
			}
		}

		#endregion

		#region Aggregates


		public static TSource Average<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where TSource : operator TSource / int
			where TSource : operator TSource + TSource
		{
			var count = 0;
			TSource sum = ?;
			using (var iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;

				switch (enumerator.GetNext())
				{
				case .Ok(let val):
					sum = val;
					count++;
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
				{
					sum += val;
					count++;
				}

				return sum / count;
			}
		}

		public static TSource Max<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where bool : operator TSource < TSource
		{
			TSource max = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): max = val;
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
				{
					let next = val;
					if (max < next)
						max = next;
				}
			}
			return max;
		}


		public static TSource Min<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where bool : operator TSource < TSource
		{
			TSource min = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): min = val;
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
				{
					let next = val;
					if (next < min)
						min = next;
				}
			}
			return min;
		}

		public static TSource Sum<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where TSource : operator TSource + TSource
		{
			TSource sum = ?;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				switch (enumerator.GetNext())
				{
				case .Ok(let val): sum = val;
				case .Err: return default;
				}

				while (enumerator.GetNext() case .Ok(let val))
					sum += val;
			}
			return sum;
		}

		public static int Count<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			var count = 0;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				while (enumerator.GetNext() case .Ok)
					count++;
			}
			return count;
		}

		#endregion

		#region Find in enumerable

		internal static bool InternalElementAt<TCollection, TSource>(TCollection items, int index, out TSource val)
			where TCollection : concrete, IEnumerable<TSource>
		{
			var index;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				while (--index > 0)
				{
					if (enumerator.GetNext() case .Err)
						break;
				}

				if (index == 0 && enumerator.GetNext() case .Ok(out val))
					return true;
			}
			val = default;
			return false;
		}

		public static TSource ElementAt<TCollection, TSource>(this TCollection items, int index)
			where TCollection : concrete, IEnumerable<TSource>
		{
			if (InternalElementAt<TCollection, TSource>(items, index, let val))
				return val;

			Runtime.FatalError("Not enough elements in the sequence.");
		}

		public static TSource ElementAtOrDefault<TCollection, TSource>(this TCollection items, int index)
			where TCollection : concrete, IEnumerable<TSource>
		{
			if (InternalElementAt<TCollection, TSource>(items, index, let val))
				return val;

			return default;
		}


		public static bool InternalFirst<TCollection, TSource>(TCollection items, out TSource val)
			where TCollection : concrete, IEnumerable<TSource>
		{
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				if (enumerator.GetNext() case .Ok(out val))
					return true;
			}

			return false;
		}

		public static TSource First<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			if (InternalFirst<TCollection, TSource>(items, let val))
				return val;
			Runtime.FatalError("Sequence contained no elements.");
		}

		public static TSource FirstOrDefault<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			if (InternalFirst<TCollection, TSource>(items, let val))
				return val;

			return default;
		}

		internal static bool InternalLast<TCollection, TSource>(TCollection items, out TSource val)
			where TCollection : concrete, IEnumerable<TSource>
		{
			var found = false;
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;
				if (enumerator.GetNext() case .Ok(out val))
					found = true;

				while (enumerator.GetNext() case .Ok(let temp))
					val = temp;
			}

			return found;
		}

		public static TSource Last<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			if (InternalLast<TCollection, TSource>(items, let val))
				return val;

			Runtime.FatalError("Sequence contained no elements.");
		}

		public static TSource LastOrDefault<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			if (InternalLast<TCollection, TSource>(items, let val))
				return val;

			return default;
		}

		internal static bool InternalSingle<TCollection, TSource>(TCollection items, out TSource val)
			where TCollection : concrete, IEnumerable<TSource>
		{
			using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
			{
				var enumerator = iterator.mEnum;

				if (enumerator.GetNext() case .Ok(out val))
				{
					if (enumerator.GetNext() case .Err)
						return true;

					Runtime.FatalError("Sequence matched more than one element.");
				}
			}

			return false;
		}

		public static TSource Single<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			if (InternalSingle<TCollection, TSource>(items, let val))
				return val;

			Runtime.FatalError("Sequence contained no elements.");
		}

		public static TSource SingleOrDefault<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			if (InternalSingle<TCollection, TSource>(items, let val))
				return val;

			return default;
		}

		#endregion

			#region Enumerable Chains
		struct Iterator
		{
			public static Iterator<decltype(default(TCollection).GetEnumerator()), TSource> Wrap<TCollection, TSource>(TCollection items)
				where TCollection : concrete, IEnumerable<TSource>
			{
				return .(items.GetEnumerator());
			}
		}

		struct Iterator<TEnum, TSource> : IDisposable
			where TEnum, IEnumerator<TSource>
		{
			internal TEnum mEnum;

			public this(TEnum items)
				{
					mEnum = items;
			}

					[SkipCall]
			public void Dispose() { }
		}

		extension Iterator<TEnum, TSource> : IDisposable where IDisposable
		{
			public void Dispose() mut => mEnum.Dispose();
		}

		struct SelectEnumerator<TSource, TEnum, TSelect, TResult> : Iterator<TEnum, TSource>, IEnumerator<TResult>, IEnumerable<TResult>
			where delegate TResult(TSource)
			where TEnum , IEnumerator< TSource>
		{
			TSelect mDlg;

			public this(TEnum e, TSelect dlg) : base(e)
				{
					mDlg = dlg;
			}

			public Result<TResult> GetNext() mut
			{
				if (mEnum.GetNext() case .Ok(let val))
					return mDlg(val);

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static SelectEnumerator<TSource, decltype(default(TCollection).GetEnumerator()), TSelect, TResult>
			Select<TCollection, TSource, TSelect, TResult>(this TCollection items, TSelect select)
			where TCollection : concrete, IEnumerable<TSource>
			where TSelect : delegate TResult(TSource)
		{
			return .(items.GetEnumerator(), select);
		}


		struct WhereEnumerator<TSource, TEnum, TPredicate> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where delegate bool(TSource)
			where TEnum , IEnumerator< TSource>
		{
			TPredicate mPredicate;

			public this(TEnum enumerator, TPredicate predicate) : base(enumerator)
				{
					mPredicate = predicate;
			}

			public Result<TSource> GetNext() mut
			{
				while (mEnum.GetNext() case .Ok(let val))
					if (mPredicate(val))
						return .Ok(val);

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static WhereEnumerator<TSource, decltype(default(TCollection).GetEnumerator()), TPredicate>
			Where<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			return .(items.GetEnumerator(), predicate);
		}

		struct TakeEnumerator<TSource, TEnum> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum, IEnumerator<TSource>
		{
			int mCount;

			public this(TEnum enumerator, int count) : base(enumerator)
				{
					mCount = count;
			}

			public Result<TSource> GetNext() mut
			{
				while (mCount-- > 0 && mEnum.GetNext() case .Ok(let val))
					return val;

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static TakeEnumerator<TSource, decltype(default(TCollection).GetEnumerator())>
			Take<TCollection, TSource>(this TCollection items, int count)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), count);
		}


		struct TakeWhileEnumerator<TSource, TEnum, TPredicate> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum, IEnumerator<TSource>
			where  delegate bool(TSource)
		{
			TPredicate mPredicate;


			public this(TEnum enumerator, TPredicate predicate) : base(enumerator)
				{
					mPredicate = predicate;
			}

			public Result<TSource> GetNext() mut
			{
				if (mEnum.GetNext() case .Ok(let val))
					if (mPredicate(val))
						return .Ok(val);

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static TakeWhileEnumerator<TSource, decltype(default(TCollection).GetEnumerator()), TPredicate>
			TakeWhile<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			return .(items.GetEnumerator(), predicate);
		}

		struct SkipEnumerator<TSource, TEnum> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum, IEnumerator<TSource>
		{
			int mCount;

			public this(TEnum enumerator, int count) : base(enumerator)
				{
					mCount = count;
			}

			public Result<TSource> GetNext() mut
			{
				while (mCount-- > 0 && mEnum.GetNext() case .Ok(?)) { }

				while (mEnum.GetNext() case .Ok(let val))
					return val;

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static SkipEnumerator<TSource, decltype(default(TCollection).GetEnumerator())>
			Skip<TCollection, TSource>(this TCollection items, int count)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), count);
		}

		struct SkipWhileEnumerator<TSource, TEnum, TPredicate> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum, IEnumerator<TSource>
			where  delegate bool(TSource)
		{
			TPredicate mPredicate;
			int mState = 0;

			public this(TEnum enumerator, TPredicate predicate) : base(enumerator)
				{
					mPredicate = predicate;
			}

			public Result<TSource> GetNext() mut
			{
				switch (mState) {
				case 0:
					while (mEnum.GetNext() case .Ok(let val))
					{
						if (!mPredicate(val))
						{
							mState = 1;
							return .Ok(val);
						}
					}
				case 1:
					return mEnum.GetNext();
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static SkipWhileEnumerator<TSource, decltype(default(TCollection).GetEnumerator()), TPredicate>
			SkipWhile<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			return .(items.GetEnumerator(), predicate);
		}

		struct DefaultIfEmptyEnumerator<TSource, TEnum> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum, IEnumerator<TSource>
		{
			TSource mDefaultValue;
			int mState = 0;

			public this(TEnum enumerator, TSource defaultValue) : base(enumerator)
				{
					mDefaultValue = defaultValue;
			}

			public Result<TSource> GetNext() mut
			{
				switch (mState) {
				case 0:
					if (mEnum.GetNext() case .Ok(let val))
					{
						mState = 1;
						return .Ok(val);
					}

					mState = 2;
					return .Ok(mDefaultValue);
				case 1:
					return mEnum.GetNext();
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static DefaultIfEmptyEnumerator<TSource, decltype(default(TCollection).GetEnumerator())>
			DefaultIfEmpty<TCollection, TSource>(this TCollection items, TSource defaultValue = default)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), default);
		}

		/*struct EmptyEnumerator<TSource, TEnum> : IEnumerator<TSource>, IEnumerable<TSource>
		where TEnum : concrete, IEnumerator<TSource>
	{
		public Result<TSource> GetNext() mut => .Err;

		public Self GetEnumerator()
		{
			return this;
		}
	}

	public static EmptyEnumerator<TSource, decltype(default(TCollection).GetEnumerator())>
		DefaultIfEmpty<TCollection, TSource>(this TCollection items, TSource defaultValue = default)
		where TCollection : concrete, IEnumerable<TSource>
	{
		return .(items.GetEnumerator(), default);
	}*/

		struct DistinctEnumerator<TSource, TEnum> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum, IEnumerator<TSource>
			where  IHashable
		{
			HashSet<TSource> mDistinctValues;
			HashSet<TSource>.Enumerator mEnum;
			Iterator<TEnum, TSource> mIterator;
			int mState = 0;

			public this(TEnum enumerator)
				{
					mIterator = .(enumerator);
				mDistinctValues = new .();
				mEnum = default;
			}

			public Result<TSource> GetNext() mut
			{
				switch (mState) {
				case 0:
					var enumerator = mIterator.mEnum;
					while (enumerator.GetNext() case .Ok(let val))
						mDistinctValues.Add(val);

					mIterator.Dispose();
					mIterator = default;
					mEnum = mDistinctValues.GetEnumerator();
					mState = 1;
					fallthrough;
				case 1:
					return mEnum.GetNext();
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mEnum.Dispose();
				DeleteAndNullify!(mDistinctValues);
			}
		}

		public static DistinctEnumerator<TSource, decltype(default(TCollection).GetEnumerator())>
			Distinct<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where TSource : IHashable
		{
			return .(items.GetEnumerator());
		}


		struct ReverseEnumerator<TSource, TEnum> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum, IEnumerator<TSource>
		{
			List<TSource> mCopyValues;
			List<TSource>.Enumerator mEnum;
			Iterator<TEnum, TSource> mIterator;
			int mIndex = -1;

			public this(TEnum enumerator)
				{
					mIterator = .(enumerator);
				mCopyValues = new .();
				mEnum = default;
			}

			public Result<TSource> GetNext() mut
			{
				switch (mIndex) {
				case -1:
					var enumerator = mIterator.mEnum;
					while (enumerator.GetNext() case .Ok(let val))
						mCopyValues.Add(val);

					mIterator.Dispose();
					mIterator = default;
					mEnum = mCopyValues.GetEnumerator();
					mIndex = mCopyValues.Count;
					fallthrough;
				default:
					if (--mIndex >= 0)
						return .Ok(mCopyValues[mIndex]);

					return .Err;
				}
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mEnum.Dispose();
				DeleteAndNullify!(mCopyValues);
			}
		}

		public static ReverseEnumerator<TSource, decltype(default(TCollection).GetEnumerator())>
			Reverse<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator());
		}

		struct MapEnumerator<TSource, TEnum, TResult> : Iterator<TEnum, TSource>, IEnumerator<TResult>, IEnumerable<TResult>
			where bool TSource<TSource
			where TSource TSource - TSource
			where TResult TResult + TResult
			where TResult TResult - TResult
			where float float / TSource
			where float TSource* float
			where float float / TResult
			where TResult float
			where TEnum , IEnumerator< TSource>
		{
			int mState = 0;
			float mScale = 0f, mMapScale;
			TSource mMin = default;
			TResult mMapMin;

			public this(TEnum enumerator, TResult mapMin, TResult mapMax) : base(enumerator)
				{
					mMapMin = mapMin;
				mMapScale = 1f / (mapMax - mapMin);
			}

			public Result<TResult> GetNext() mut
			{
				switch (mState) {
				case 0:
					var copyEnum = mEnum;
					switch (copyEnum.GetNext()) {
					case .Ok(let first):
						var min = first;
						var max = first;

						while (copyEnum.GetNext() case .Ok(let next))
						{
							if (next < min) min = next;
							if (max < next) max = next;
						}

						mMin = min;
						mScale = 1f / (max - min);
						if (mScale == default)
						{
							mState = 2;
							return .Ok(default);
						}

						mState = 1;
					case .Err: return .Err;
					}
					fallthrough;
				case 1:
					if (mEnum.GetNext() case .Ok(let val))
						return (TResult)(((val - mMin) * mScale) / mMapScale) + mMapMin;
				case 2:
					if (mEnum.GetNext() case .Ok(let val))
						return .Ok(default);
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static MapEnumerator<TSource, decltype(default(TCollection).GetEnumerator()), TResult>
			Map<TCollection, TSource, TResult>(this TCollection items, TResult min, TResult max)
			where TCollection : concrete, IEnumerable<TSource>
			where bool : operator TSource < TSource
			where TSource : operator TSource - TSource
			where TResult : operator TResult + TResult
			where TResult : operator TResult - TResult
			where float : operator float / TSource
			where float : operator TSource * float
			where float : operator float / TResult
			where TResult : operator explicit float
		{
			return .(items.GetEnumerator(), min, max);
		}
		#endregion

		#region ToXYZ methods
		public static void ToDictionary<TCollection, TSource, TKeyDlg, TKey, TValueDlg, TValue>(this TCollection items, TKeyDlg keyDlg, TValueDlg valueDlg, Dictionary<TKey, TValue> output)
			where TCollection : concrete, IEnumerable<TSource>
			where TKey : IHashable
			where TKeyDlg : delegate TKey(TSource)
			where TValueDlg : delegate TValue(TSource)
		{
			for (var it in items)
				output.Add(keyDlg(it), valueDlg(it));
		}

		public static void ToDictionary<TCollection, TSource, TKeyDlg, TKey>(this TCollection items, TKeyDlg keyDlg, Dictionary<TKey, TSource> output)
			where TCollection : concrete, IEnumerable<TSource>
			where TKey : IHashable
			where TKeyDlg : delegate TKey(TSource)
		{
			for (var it in items)
				output.Add(keyDlg(it), it);
		}

		public static void ToHashSet<TCollection, TSource>(this TCollection items, HashSet<TSource> output)
			where TCollection : concrete, IEnumerable<TSource>
			where TSource : IHashable
		{
			for (var it in items)
				output.Add(it);
		}

		public static void ToList<T, TSource>(this T items, List<TSource> output)
			where T : concrete, IEnumerable<TSource>
		{
			for (var it in items)
				output.Add(it);
		}
		#endregion

		/*public static TSource
		Aggregate<TCollection, TSource, TAccumulate>(this TCollection items, TAccumulate accumulate)
		where TCollection : concrete, IEnumerable<TSource>
		where TAccumulate : delegate TSource(TSource, TSource)
	{
		if (InternalAggregate(items, default(TSource), accumulate, let result))
			return result;

		Runtime.FatalError("No elements in the sequence.");
	}

	public static TAccumulate
		Aggregate<TCollection, TSource, TAccumulate, TAccDlg>(this TCollection items, TAccumulate seed, TAccDlg
	accumulate) where TCollection : concrete, IEnumerable<TSource> where TAccDlg : delegate TAccumulate(TAccumulate,
	TSource)
	{
		if (InternalAggregate(items, default(TAccumulate), accumulate, let result))
			return result;

		return seed;
	}

	public static TResult
		Aggregate<TCollection, TSource, TAccumulate, TAccDlg, TResult, TResDlg>(this TCollection items, TAccumulate
	seed, TAccDlg accumulate, TResDlg resultSelector) where TCollection : concrete, IEnumerable<TSource> where
	TAccDlg : delegate TAccumulate(TAccumulate, TSource) where TResDlg : delegate TResult(TAccumulate)
	{
		if (InternalAggregate(items, default(TAccumulate), accumulate, let result))
			return resultSelector(result);

		return resultSelector(seed);
	}


	internal static bool InternalAggregate<TCollection, TSource, TAccumulate, TAccDlg>(TCollection items,
	TAccumulate seed, TAccDlg func, out TAccumulate result) where TCollection : concrete, IEnumerable<TSource> where
	TAccDlg : delegate TAccumulate(TAccumulate, TSource)
	{
		TAccumulate sum = seed;
		var accumulated = false;
		using (let iterator = Iterator.Wrap<TCollection, TSource>(items))
		{
			var enumerator = iterator.mEnum;

			if (enumerator.GetNext() case .Ok(let val))
			{
				sum = func(sum, val);
				accumulated = true;
			}

			if (accumulated)
				while (enumerator.GetNext() case .Ok(let val))
					sum = func(sum, val);
		}

		result = sum;
		return accumulated;
	}*/


		struct OfTypeEnumerator<TSource, TEnum, TOf> : Iterator<TEnum, TSource>, IEnumerator<TOf>, IEnumerable<TOf>
			where TEnum, IEnumerator<TSource>
			where TSource
		{
			public this(TEnum enumerator) : base(enumerator)
				{
				}

			public Result<TOf> GetNext() mut
			{
				while (mEnum.GetNext() case .Ok(let val))
				{
					if (val is TOf)
						return .Ok(*(TOf*)Internal.UnsafeCastToPtr(val));
				}
				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}
		}

		public static OfTypeEnumerator<TSource, decltype(default(TCollection).GetEnumerator()), TOf>
			OfType<TCollection, TSource, TOf>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator());
		}
	}
}
