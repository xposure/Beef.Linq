using System.Collections;
using System;
using internal System.Linq;

namespace System.Linq
{
	public static
	{
		public static class Enumerable
		{
			public struct EmptyEnumerable<TSource> : IEnumerable<TSource>, IEnumerator<TSource>
			{
				public Self GetEnumerator()
				{
					return this;
				}

				public Result<TSource> GetNext()
				{
					return .Err;
				}
			}

			public static EmptyEnumerable<TSource> Empty<TSource>() => .();

			public struct RangeEnumerable<TSource> : IEnumerator<TSource>, IEnumerable<TSource> where TSource : operator TSource + int
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

			public static RangeEnumerable<TSource>
				Range<TSource>(TSource count)
				where TSource : operator TSource + int
			{
				return .(default, count);
			}

			public static RangeEnumerable<TSource>
				Range<TSource>(TSource start, TSource end)
				where TSource : operator TSource + int
				where TSource : operator TSource + TSource
			{
				return .(start, end);
			}

			public struct RepeatEnumerable<TSource> : IEnumerator<TSource>, IEnumerable<TSource>
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

			public static RepeatEnumerable<TSource>
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
			using (var iterator = Iterator.Wrap(items))
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
			using (var iterator0 = Iterator.Wrap<TLeft, TSource>(left))
			{
				var e0 = iterator0.mEnum;
				using (var iterator1 = Iterator.Wrap<TRight, TSource>(right))
				{
					var e1 = iterator1.mEnum;
					while (true)
					{
						switch (e0.GetNext())
						{
						case .Ok(let i0):
							switch (e1.GetNext())
							{
							case .Ok(let i1):
								if (i0 != i1)
									return false;
							case .Err:
								return false;
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
			using (var iterator = Iterator.Wrap(items))
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

		public static TSource Average<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TSource : operator TSource / int
			where TSource : operator TSource + TSource
			where TPredicate : delegate bool(TSource)
		{
			var count = 0;
			TSource sum = ?;
			using (var iterator = Iterator.Wrap(items.Where(predicate)))
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
			using (var iterator = Iterator.Wrap(items))
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
			using (var iterator = Iterator.Wrap<TCollection, TSource>(items))
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

		public static TSource Sum<TCollection, TSource, TPredicate>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
			where TSource : operator TSource + TSource
		{
			TSource sum = ?;
			using (var iterator = Iterator.Wrap(items))
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
			if (typeof(TCollection) == typeof(List<TSource>))
				return (items as List<TSource>).Count;
			if (typeof(TCollection) == typeof(TSource[]))
				return (items as TSource[]).Count;

			var count = 0;
			using (var iterator = Iterator.Wrap<TCollection, TSource>(items))
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
			using (var iterator = Iterator.Wrap(items))
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
			using (var iterator = Iterator.Wrap<TCollection, TSource>(items))
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
			using (var iterator = Iterator.Wrap(items))
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
			using (var iterator = Iterator.Wrap<TCollection, TSource>(items))
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
			where TEnum : concrete, IEnumerator<TSource>
		{
			internal TEnum mEnum;

			public this(TEnum items)
			{
				mEnum = items;
			}

			[SkipCall]
			public void Dispose() mut { }

			public static implicit operator Iterator<TEnum, TSource>(TEnum enumerator) => .(enumerator);
		}

		extension Iterator<TEnum, TSource> : IDisposable where TEnum : IDisposable
		{
			public void Dispose() mut => mEnum.Dispose();
		}

		struct Wrap
		{
			public static WrapEnumerable<decltype(default(TCollection).GetEnumerator()), TSource> Wrap<TCollection, TSource>(TCollection items)
				where TCollection : concrete, IEnumerable<TSource>
			{
				return .(items.GetEnumerator());
			}
		}

		struct WrapEnumerable<TEnum, TValue> : IEnumerable<TValue>, IEnumerator<TValue>
			where TEnum : concrete, IEnumerator<TValue>
		{
			private TEnum mEnum;
			public this(TEnum enumerator)
			{
				mEnum = enumerator;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public Result<TValue> GetNext() mut => mEnum.GetNext();
		}

		struct SelectEnumerable<TSource, TEnum, TSelect, TResult> : Iterator<TEnum, TSource>, IEnumerator<TResult>, IEnumerable<TResult>
			where TSelect : delegate TResult(TSource)
			where TEnum : concrete, IEnumerator<TSource>
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

		public static SelectEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TSelect, TResult>
			Select<TCollection, TSource, TSelect, TResult>(this TCollection items, TSelect select)
			where TCollection : concrete, IEnumerable<TSource>
			where TSelect : delegate TResult(TSource)
		{
			return .(items.GetEnumerator(), select);
		}


		struct WhereEnumerable<TSource, TEnum, TPredicate> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
			where TEnum : concrete, IEnumerator<TSource>
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

		public static WhereEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TPredicate>
			Where<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			return .(items.GetEnumerator(), predicate);
		}

		struct TakeEnumerable<TSource, TEnum> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum : concrete, IEnumerator<TSource>
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

		public static TakeEnumerable<TSource, decltype(default(TCollection).GetEnumerator())>
			Take<TCollection, TSource>(this TCollection items, int count)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), count);
		}


		struct TakeWhileEnumerable<TSource, TEnum, TPredicate> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum : concrete, IEnumerator<TSource>
			where TPredicate : delegate bool(TSource)
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

		public static TakeWhileEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TPredicate>
			TakeWhile<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			return .(items.GetEnumerator(), predicate);
		}

		struct SkipEnumerable<TSource, TEnum> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum : concrete, IEnumerator<TSource>
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

		public static SkipEnumerable<TSource, decltype(default(TCollection).GetEnumerator())>
			Skip<TCollection, TSource>(this TCollection items, int count)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), count);
		}

		struct SkipWhileEnumerable<TSource, TEnum, TPredicate> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum : concrete, IEnumerator<TSource>
			where TPredicate : delegate bool(TSource)
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

		public static SkipWhileEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TPredicate>
			SkipWhile<TCollection, TSource, TPredicate>(this TCollection items, TPredicate predicate)
			where TCollection : concrete, IEnumerable<TSource>
			where TPredicate : delegate bool(TSource)
		{
			return .(items.GetEnumerator(), predicate);
		}

		struct DefaultIfEmptyEnumerable<TSource, TEnum> : Iterator<TEnum, TSource>, IEnumerator<TSource>, IEnumerable<TSource>
			where TEnum : concrete, IEnumerator<TSource>
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

		public static DefaultIfEmptyEnumerable<TSource, decltype(default(TCollection).GetEnumerator())>
			DefaultIfEmpty<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), default);
		}

		public static DefaultIfEmptyEnumerable<TSource, decltype(default(TCollection).GetEnumerator())>
			DefaultIfEmpty<TCollection, TSource>(this TCollection items, TSource defaultValue = default)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), defaultValue);
		}

		struct DistinctEnumerable<TSource, TEnum> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum : concrete, IEnumerator<TSource>
			where TSource : IHashable
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

		public static DistinctEnumerable<TSource, decltype(default(TCollection).GetEnumerator())>
			Distinct<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where TSource : IHashable
		{
			return .(items.GetEnumerator());
		}

		struct ReverseEnumerable<TSource, TEnum> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum : concrete, IEnumerator<TSource>
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

		public static ReverseEnumerable<TSource, decltype(default(TCollection).GetEnumerator())>
			Reverse<TCollection, TSource>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator());
		}

		struct MapEnumerable<TSource, TEnum, TResult> : Iterator<TEnum, TSource>, IEnumerator<TResult>, IEnumerable<TResult>
			where bool : operator TSource < TSource
			where TSource : operator TSource - TSource
			where TResult : operator TResult + TResult
			where TResult : operator TResult - TResult
			where float : operator float / TSource
			where float : operator TSource * float
			where float : operator float / TResult
			where TResult : operator explicit float
			where TEnum : concrete, IEnumerator<TSource>
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

		public static MapEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TResult>
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

#region Aggregates
		public static TSource
			Aggregate<TCollection, TSource, TAccumulate>(this TCollection items, TAccumulate accumulate)
			where TCollection : concrete, IEnumerable<TSource>
			where TAccumulate : delegate TSource(TSource, TSource)
		{
			if (InternalAggregate(items, default(TSource), accumulate, let result))
				return result;

			Runtime.FatalError("No elements in the sequence.");
		}

		public static TAccumulate
			Aggregate<TCollection, TSource, TAccumulate, TAccDlg>(this TCollection items, TAccumulate seed, TAccDlg accumulate)
			where TCollection : concrete, IEnumerable<TSource>
			where TAccDlg : delegate TAccumulate(TAccumulate, TSource)
		{
			if (InternalAggregate(items, seed, accumulate, let result))
				return result;

			return seed;
		}

		public static TResult
			Aggregate<TCollection, TSource, TAccumulate, TAccDlg, TResult, TResDlg>(this TCollection items, TAccDlg accumulate, TResDlg resultSelector)
			where TCollection : concrete, IEnumerable<TSource>
			where TAccDlg : delegate TAccumulate(TAccumulate, TSource)
			where TResDlg : delegate TResult(TAccumulate)
		{
			if (InternalAggregate(items, default(TAccumulate), accumulate, let result))
				return resultSelector(result);

			return resultSelector(default);
		}

		public static TResult
			Aggregate<TCollection, TSource, TAccumulate, TAccDlg, TResult, TResDlg>(this TCollection items, TAccumulate seed, TAccDlg accumulate, TResDlg resultSelector)
			where TCollection : concrete, IEnumerable<TSource>
			where TAccDlg : delegate TAccumulate(TAccumulate, TSource)
			where TResDlg : delegate TResult(TAccumulate)
		{
			if (InternalAggregate(items, seed, accumulate, let result))
				return resultSelector(result);

			return resultSelector(seed);
		}

		internal static bool
			InternalAggregate<TCollection, TSource, TAccumulate, TAccDlg>(TCollection items, TAccumulate seed, TAccDlg func, out TAccumulate result)
			where TCollection : concrete, IEnumerable<TSource>
			where TAccDlg : delegate TAccumulate(TAccumulate, TSource)
		{
			TAccumulate sum = seed;
			var accumulated = false;
			using (var iterator = Iterator.Wrap(items))
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
		}
		#endregion

#region GroupBy

		struct DynamicArray<TValue> : IDisposable
		{
			TValue[] mPtr = default;
			Span<TValue> mSpan = default;
			int mLength = 0;
			int mSize = 4;
			int mIndex = 0;

			public int Length => mLength;

			public this()
			{
				this.mPtr = new TValue[mSize];
				this.mLength = 0;
			}

			public ref TValue this[int index] => ref mPtr[index];

			public void Dispose() mut
			{
				DeleteAndNullify!(mPtr);
				mPtr = null;
			}
			public void Add(TValue value) mut
			{
				if (mLength + 1 > mSize)
				{
					var newSize = mSize * 3 / 2;
					var dst = new TValue[newSize];
					Array.Copy(mPtr, dst, mLength);
					Swap!(mPtr, dst);
					delete dst;
				}
				mPtr[mLength++] = value;
			}

			public Span<TValue>.Enumerator GetEnumerator() mut
			{
				mSpan = .(mPtr, 0, mLength);
				return mSpan.GetEnumerator();
			}
		}

		public extension DynamicArray<TValue> : IDisposable
			where TValue : IDisposable
		{
			public void Dispose() mut
			{
				for (var it in mPtr)
					it.Dispose();

				base.Dispose();
			}
		}

		public struct Grouping<TKey, TValue> : IEnumerable<TValue>, IEnumerator<TValue>, IDisposable, IResettable
		{
			List<TValue> mValues;
			int mIndex = 0;
			public readonly TKey Key;

			public this(TKey key)
			{
				Key = key;
				mValues = new .();
			}

			public void Reset() mut
			{
				mIndex = 0;
			}

			public Result<TValue> GetNext() mut
			{
				if (mIndex == mValues.Count)
					return .Err;

				return .Ok(mValues[mIndex++]);
			}

			public List<TValue>.Enumerator GetEnumerator()
			{
				return mValues.GetEnumerator();
			}

			public void Add(TValue value) mut
			{
				mValues.Add(value);
			}

			public void Dispose() mut
			{
				DeleteAndNullify!(mValues);
			}
		}

		public class GroupByResult<TKey, TValue> :
			IEnumerator<Grouping<TKey, TValue>>, IRefEnumerator<Grouping<TKey, TValue>*>, IEnumerable<Grouping<TKey, TValue>>, IResettable
			where bool : operator TKey == TKey//where TKey : IHashable
		{
			DynamicArray<Grouping<TKey, TValue>> mResults = .() ~ mResults.Dispose();
			int mIndex = 0;

			public int Count => mResults.Length;

			public this()
			{
			}

			public void Reset()
			{
				mIndex = 0;
			}

			public Result<Grouping<TKey, TValue>> GetNext()
			{
				if (mIndex < mResults.Length)
					return .Ok(mResults[mIndex++]);

				return .Err;
			}

			public Span<Grouping<TKey, TValue>>.Enumerator GetEnumerator()
			{
				return mResults.GetEnumerator();
			}

			public Result<Grouping<TKey, TValue>*> GetNextRef()
			{
				if (mIndex < mResults.Length)
					return .Ok(&mResults[mIndex++]);

				return .Err;
			}

			public ref Grouping<TKey, TValue> this[int index] => ref mResults[index];

			public void Add(Grouping<TKey, TValue> group)
			{
				mResults.Add(group);
			}
		}

		public struct GroupByEnumerable<TSource, TEnum, TKey, TKeyDlg, TValue, TValueDlg> :
			IEnumerator<Grouping<TKey, TValue>>, IEnumerable<Grouping<TKey, TValue>>, IDisposable

			where TEnum : concrete, IEnumerator<TSource>
			where bool : operator TKey == TKey//where TKey : IHashable
			where TKeyDlg : delegate TKey(TSource)
			where TValueDlg : delegate TValue(TSource)
		{
			GroupByResult<TKey, TValue> mResults;
			TKeyDlg mKeyDlg;
			TValueDlg mValueDlg;
			Iterator<TEnum, TSource> mIterator;
			int mIndex = -1;

			public this(GroupByResult<TKey, TValue> results, TEnum enumerator, TKeyDlg keyDlg, TValueDlg valueDlg)
			{
				mResults = results;
				mIterator = .(enumerator);
				mKeyDlg = keyDlg;
				mValueDlg = valueDlg;
			}

			public Result<Grouping<TKey, TValue>> GetNext() mut
			{
				if (mIndex == -1)
				{
					while (mIterator.mEnum.GetNext() case .Ok(let val))
					{
						let k = mKeyDlg(val);
						let v = mValueDlg(val);
						var added = false;
						for (var it in ref mResults)
						{
							if (it.Key == k)
							{
								it.Add(v);
								added = true;
							}
						}

						if (!added)
						{
							var group = mResults.Add(.. .(k));
							group.Add(v);
						}
					}
					mIndex = 0;
				}

				if (mIndex < mResults.Count)
					return mResults[mIndex++];

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mIterator.Dispose();
			}
		}

		public static GroupByEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TKey, TKeyDlg, TSource, delegate TSource(TSource)>
			GroupBy<TCollection, TSource, TKey, TKeyDlg>(this TCollection items, TKeyDlg key, GroupByResult<TKey, TSource> results)
			where TCollection : concrete, IEnumerable<TSource>
			where TKeyDlg : delegate TKey(TSource)
			where TKey : IHashable
		{
			//guess we could optimize out this scope with some code duplication
			return .(results, items.GetEnumerator(), key, scope (val) => val);
		}

		/*public static GroupByEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TKey, TKeyDlg,
		TSource, delegate TSource(TSource)> GroupBy<TCollection, TSource, TKey, TKeyDlg>(this TCollection items, TKeyDlg
		key, GroupByResult<TKey, TSource> results) where TCollection : concrete, IEnumerable<TSource> where TKeyDlg :
		delegate TKey(TSource) where TKey : IHashable
		{
			//guess we could optimize out this scope with some code duplication
			return .(results, items.GetEnumerator(), key, scope (val) => val);
		}*/
#endregion
		struct UnionEnumerable<TSource, TEnum, TEnum2> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum : concrete, IEnumerator<TSource>
			where TEnum2 : concrete, IEnumerator<TSource>
			where TSource : IHashable
		{
			HashSet<TSource> mDistinctValues;
			Iterator<TEnum, TSource> mSource;
			Iterator<TEnum2, TSource> mOther;
			int mState = 0;

			public this(TEnum sourceEnumerator, TEnum2 otherEnumerator)
			{
				mSource = sourceEnumerator;
				mOther = otherEnumerator;

				mDistinctValues = new .();
			}

			public Result<TSource> GetNext() mut
			{
				switch (mState) {
				case 0:
					var e = mSource.mEnum;
					while (e.GetNext() case .Ok(let val))
						if (mDistinctValues.Add(val))
							return .Ok(val);

					mState++;
					fallthrough;
				case 1:
					var e = mOther.mEnum;
					while (e.GetNext() case .Ok(let val))
						if (mDistinctValues.Add(val))
							return .Ok(val);

					mState++;
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mSource.Dispose();
				mOther.Dispose();
				DeleteAndNullify!(mDistinctValues);
			}
		}

		public static UnionEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), decltype(default(TCollection2).GetEnumerator())>
			Union<TCollection, TCollection2, TSource>(this TCollection items, TCollection2 other)
			where TCollection : concrete, IEnumerable<TSource>
			where TCollection2 : concrete, IEnumerable<TSource>
			where TSource : IHashable
		{
			return .(items.GetEnumerator(), other.GetEnumerator());
		}

		struct ExceptEnumerable<TSource, TEnum, TEnum2> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum : concrete, IEnumerator<TSource>
			where TEnum2 : concrete, IEnumerator<TSource>
			where TSource : IHashable
		{
			HashSet<TSource> mDistinctValues;
			Iterator<TEnum, TSource> mSource;
			Iterator<TEnum2, TSource> mOther;
			int mState = 0;

			public this(TEnum sourceEnumerator, TEnum2 otherEnumerator)
			{
				mSource = sourceEnumerator;
				mOther = otherEnumerator;

				mDistinctValues = new .();
			}

			public Result<TSource> GetNext() mut
			{
				switch (mState) {
				case 0:
					var e = mOther.mEnum;
					while (e.GetNext() case .Ok(let val))
						mDistinctValues.Add(val);

					mState++;
					fallthrough;
				case 1:
					var e = mSource.mEnum;
					while (e.GetNext() case .Ok(let val))
						if (mDistinctValues.Add(val))
							return .Ok(val);

					mState++;
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mSource.Dispose();
				mOther.Dispose();
				DeleteAndNullify!(mDistinctValues);
			}
		}

		public static ExceptEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), decltype(default(TCollection2).GetEnumerator())>
			Except<TCollection, TCollection2, TSource>(this TCollection items, TCollection2 other)
			where TCollection : concrete, IEnumerable<TSource>
			where TCollection2 : concrete, IEnumerable<TSource>
			where TSource : IHashable
		{
			return .(items.GetEnumerator(), other.GetEnumerator());
		}

		struct IntersectEnumerable<TSource, TEnum, TEnum2> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum : concrete, IEnumerator<TSource>
			where TEnum2 : concrete, IEnumerator<TSource>
			where TSource : IHashable
		{
			HashSet<TSource> mDistinctValues;
			Iterator<TEnum, TSource> mSource;
			Iterator<TEnum2, TSource> mIntersect;
			int mState = 0;

			public this(TEnum sourceEnumerator, TEnum2 intersectEnumerator)
			{
				mSource = .(sourceEnumerator);
				mIntersect = .(intersectEnumerator);
				mDistinctValues = new .();
			}

			public Result<TSource> GetNext() mut
			{
				switch (mState)
				{
				case 0:
					var e = mSource.mEnum;
					while (e.GetNext() case .Ok(let val))
						mDistinctValues.Add(val);

					mState++;
					fallthrough;
				case 1:
					var e = mIntersect.mEnum;
					while (e.GetNext() case .Ok(let val))
						if (mDistinctValues.Remove(val))
							return .Ok(val);

					mState++;
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mSource.Dispose();
				mIntersect.Dispose();
				DeleteAndNullify!(mDistinctValues);
			}
		}

		public static IntersectEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), decltype(default(TCollection2).GetEnumerator())>
			Intersect<TCollection, TCollection2, TSource>(this TCollection items, TCollection2 other)
			where TCollection : concrete, IEnumerable<TSource>
			where TCollection2 : concrete, IEnumerable<TSource>
			where TSource : IHashable
		{
			return .(items.GetEnumerator(), other.GetEnumerator());
		}

		struct ZipEnumerable<TSource, TEnum, TEnum2, TResult, TSelect> : IEnumerator<TResult>, IEnumerable<TResult>, IDisposable
			where TEnum : concrete, IEnumerator<TSource>
			where TEnum2 : concrete, IEnumerator<TSource>
			where TSelect : delegate TResult(TSource first, TSource second)
		{
			Iterator<TEnum, TSource> mSource;
			Iterator<TEnum2, TSource> mOther;
			TSelect mSelect;

			public this(TEnum sourceEnumerator, TEnum2 otherEnumerator, TSelect select)
			{
				mSource = sourceEnumerator;
				mOther = otherEnumerator;
				mSelect = select;
			}

			public Result<TResult> GetNext() mut
			{
				if (mSource.mEnum.GetNext() case .Ok(let first))
					if (mOther.mEnum.GetNext() case .Ok(let second))
						return mSelect(first, second);

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mSource.Dispose();
				mOther.Dispose();
			}
		}

		public static ZipEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), decltype(default(TCollection2).GetEnumerator()), TResult, TSelect>
			Zip<TCollection, TCollection2, TSource, TResult, TSelect>(this TCollection items, TCollection2 other, TSelect select)
			where TCollection : concrete, IEnumerable<TSource>
			where TCollection2 : concrete, IEnumerable<TSource>
			where TSelect : delegate TResult(TSource first, TSource second)
		{
			return .(items.GetEnumerator(), other.GetEnumerator(), select);
		}

		struct ConcatEnumerable<TSource, TEnum, TEnum2> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum : concrete, IEnumerator<TSource>
			where TEnum2 : concrete, IEnumerator<TSource>
		{
			Iterator<TEnum, TSource> mFirst;
			Iterator<TEnum2, TSource> mSecond;
			int mState = 0;

			public this(TEnum firstEnumerator, TEnum2 secondEnumerator)
			{
				mFirst = firstEnumerator;
				mSecond = secondEnumerator;
			}

			public Result<TSource> GetNext() mut
			{
				switch (mState) {
				case 0:
					if (mFirst.mEnum.GetNext() case .Ok(let val))
						return .Ok(val);

					mState++;
					fallthrough;
				case 1:
					if (mSecond.mEnum.GetNext() case .Ok(let val))
						return .Ok(val);

					mState++;
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mFirst.Dispose();
				mSecond.Dispose();
			}
		}

		public static ConcatEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), decltype(default(TCollection2).GetEnumerator())>
			Concat<TCollection, TCollection2, TSource>(this TCollection items, TCollection2 other)
			where TCollection : concrete, IEnumerable<TSource>
			where TCollection2 : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), other.GetEnumerator());
		}

		public static ConcatEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), decltype(default(TCollection2).GetEnumerator())>
			Append<TCollection, TCollection2, TSource>(this TCollection items, TCollection2 other)
			where TCollection : concrete, IEnumerable<TSource>
			where TCollection2 : concrete, IEnumerable<TSource>
		{
			return .(items.GetEnumerator(), other.GetEnumerator());
		}

		public static ConcatEnumerable<TSource, decltype(default(TCollection2).GetEnumerator()), decltype(default(TCollection).GetEnumerator())>
			Prepend<TCollection, TCollection2, TSource>(this TCollection items, TCollection2 other)
			where TCollection : concrete, IEnumerable<TSource>
			where TCollection2 : concrete, IEnumerable<TSource>
		{
			return .(other.GetEnumerator(), items.GetEnumerator());
		}

		static class OrderByComparison<T>
			where int : operator T <=> T
		{
			typealias TCompare = delegate int(T lhs, T rhs);
			public readonly static TCompare Comparison = (new (lhs, rhs) => lhs <=> rhs) ~ delete _;
		}

		struct SortedEnumerable<TSource, TEnum, TKey, TKeyDlg, TCompare> : IEnumerator<(TKey key, TSource value)>, IEnumerable<(TKey key, TSource value)>, IDisposable
			where TEnum : concrete, IEnumerator<TSource>
			where TKeyDlg : delegate TKey(TSource)
			where TCompare : delegate int(TKey lhs, TKey rhs)
		{
			List<(TKey key, TSource value)> mOrderedList;
			Iterator<TEnum, TSource> mIterator;
			TKeyDlg mKey;
			TCompare mCompare;
			int mIndex;
			int mCount = 0;
			bool mDescending;

			public this(TEnum firstEnumerator, TKeyDlg key, TCompare compare, bool descending)
			{
				mOrderedList = new .();
				mKey = key;
				mIterator = firstEnumerator;
				mCompare = compare;
				mIndex = -1;
				mDescending = descending;
			}

			public Result<(TKey key, TSource value)> GetNext() mut
			{
				if (mIndex == -1)
				{
					while (mIterator.mEnum.GetNext() case .Ok(let val))
						mOrderedList.Add((mKey(val), val));

					mOrderedList.Sort(scope (l, r) => mCompare(l.key, r.key));
					mCount = mOrderedList.Count;//keeping vars local
					mIndex = mDescending ? mCount : 0;
				}

				if (mDescending)
				{
					if (mIndex > 0)
						return .Ok(mOrderedList[--mIndex]);
				}
				else if (mIndex < mCount)
					return .Ok(mOrderedList[mIndex++]);

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mIterator.Dispose();
				DeleteAndNullify!(mOrderedList);
			}
		}
		
		struct SubSortEnumerable<TEnum2, TSource, TKey, TKey2, TKeyDlg2, TCompare2> : IEnumerator<(TKey2 key, TSource value)>, IEnumerable<(TKey2 key, TSource value)>, IDisposable
			where TEnum2 : concrete, IEnumerator<(TKey key, TSource value)>//, IDisposable
			where TKeyDlg2 : delegate TKey2(TSource)
			where TCompare2 : delegate int(TKey2 lhs, TKey2 rhs)
		{
			typealias KVP = (TKey key, TSource value);
			typealias KVP2 = (TKey2 key, TSource value);
			List<KVP2> mOrderedList;
			Iterator<TEnum2, KVP> mSorted;
			TKeyDlg2 mKey;
			TCompare2 mCompare;
			int mIndex;
			int mCount = 0;
			int mFlags;
			KVP mCurrent = default;
			KVP mNext = default;

			public this(TEnum2 sorted, TKeyDlg2 key, TCompare2 compare, bool descending)
			{
				mSorted = sorted;
				mOrderedList = new .();
				mKey = key;
				mCompare = compare;
				mFlags = descending ? 1 : 0;
				mIndex = -1;
			}

			public Result<(TKey2 key, TSource value)> GetNext() mut
			{
				if (mIndex == -1)
				{
					if (mSorted.mEnum.GetNext() case .Ok(out mNext))
					{
						mIndex = 0;
						mCount = 0;
					}
					else
						return .Err;
				}

				if ((mIndex == 0 || mIndex == mCount) && (mFlags & 2) == 0)
				{
					mOrderedList.Clear();
					while (mCurrent.key == mNext.key)
					{
						mOrderedList.Add((mKey(mNext.value), mNext.value));
						if (!(mSorted.mEnum.GetNext() case .Ok(out mNext)))
						{
							mFlags |= 2;
							break;
						}
					}

					if (mOrderedList.Count > 1)
						mOrderedList.Sort(scope (l, r) => mCompare(l.key, r.key));

					mCount = mOrderedList.Count;
					mIndex = ((mFlags & 1) == 1) ? mCount : 0;
				}

				if (mOrderedList.Count > 0)
				{
					if ((mFlags & 1) == 1)
					{
						if (mIndex > 0)
							return .Ok(mOrderedList[--mIndex]);
					}
					else if (mIndex < mCount)
						return .Ok(mOrderedList[mIndex++]);
				}

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mSorted.Dispose();
				DeleteAndNullify!(mOrderedList);
			}

			/*internal ThenByEnumerable<decltype(default(Self).GetEnumerator()),TSource, TKey,  TKey2, TKeyDlg2, TCompare2>
				Then<TEnum2, TKey2, TKeyDlg2, TCompare2>(TKeyDlg2 key, TCompare2 compare, bool descending)
				where TEnum2: concrete, IEnumerator<(TKey key, TSource value)>
				where TKeyDlg2: delegate TKey2(TSource)
				where TCompare2 : delegate int(TKey2 lhs, TKey2 rhs)
			{
				return .(mSorted.GetEnumerator(), key, compare, descending);
			}*/
		}

		struct OrderByEnumerable<TSource, TEnum, TKey, TKeyDlg, TCompare> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum : concrete, IEnumerator<TSource>
			where TKeyDlg : delegate TKey(TSource)
			where TCompare : delegate int(TKey lhs, TKey rhs)
		{
			typealias sortedEnumerable = SortedEnumerable<TSource, TEnum, TKey, TKeyDlg, TCompare>;
			sortedEnumerable mSorted;

			public this(TEnum enumerator, TKeyDlg key, TCompare compare, bool descending)
			{
				mSorted = .(enumerator, key, compare, descending);
			}

			public Result<TSource> GetNext() mut
			{
				if (mSorted.GetNext() case .Ok(let val))
					return .Ok(val.value);

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mSorted.Dispose();
			}

			public SubSortEnumerable<decltype(default(sortedEnumerable).GetEnumerator()),TSource, TKey,  TKey2, TKeyDlg2, TCompare2>
				ThenBy<TEnum2, TKey2, TKeyDlg2, TCompare2>(TKeyDlg2 key, TCompare2 compare)
				where TEnum2: concrete, IEnumerator<(TKey key, TSource value)>
				where TKeyDlg2: delegate TKey2(TSource)
				where TCompare2 : delegate int(TKey2 lhs, TKey2 rhs)
			{
				return .(mSorted.GetEnumerator(), key, compare, false);
			}

			public SubSortEnumerable<decltype(default(sortedEnumerable).GetEnumerator()),TSource, TKey,  TKey2, TKeyDlg2, TCompare2>
				ThenBy<TEnum2, TKey2, TKeyDlg2>(TKeyDlg2 key)
				where TEnum2: concrete, IEnumerator<(TKey key, TSource value)>
				where TKeyDlg2: delegate TKey2(TSource)
				where int : operator TKey2 <=> TKey2
			{
				return .(mSorted.GetEnumerator(), key, OrderByComparison<TKey2>.Comparison, false);
			}
		}

		public static OrderByEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TKey, TKeyDlg, delegate int(TKey lhs, TKey rhs)>
			OrderBy<TCollection, TSource, TKey, TKeyDlg>(this TCollection items, TKeyDlg keySelect)
			where TCollection : concrete, IEnumerable<TSource>
			where TKeyDlg : delegate TKey(TSource)
			where int : operator TKey <=> TKey
		{
			return .(items.GetEnumerator(), keySelect, OrderByComparison<TKey>.Comparison, false);
		}

		public static OrderByEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TKey, TKeyDlg, TCompare>
			OrderBy<TCollection, TSource, TKey, TKeyDlg, TCompare>(this TCollection items, TKeyDlg keySelect, TCompare comparison)
			where TCollection : concrete, IEnumerable<TSource>
			where TKeyDlg : delegate TKey(TSource)
			where TCompare : delegate int(TKey lhs, TKey rhs)
		{
			return .(items.GetEnumerator(), keySelect, comparison, false);
		}

		public static OrderByEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TKey, TKeyDlg, delegate int(TKey lhs, TKey rhs)>
			OrderByDescending<TCollection, TSource, TKey, TKeyDlg>(this TCollection items, TKeyDlg keySelect)
			where TCollection : concrete, IEnumerable<TSource>
			where TKeyDlg : delegate TKey(TSource)
			where int : operator TKey <=> TKey
		{
			return .(items.GetEnumerator(), keySelect, OrderByComparison<TKey>.Comparison, true);
		}

		public static OrderByEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TKey, TKeyDlg, TCompare>
			OrderByDescending<TCollection, TSource, TKey, TKeyDlg, TCompare>(this TCollection items, TKeyDlg keySelect, TCompare comparison)
			where TCollection : concrete, IEnumerable<TSource>
			where TKeyDlg : delegate TKey(TSource)
			where TCompare : delegate int(TKey lhs, TKey rhs)
		{
			return .(items.GetEnumerator(), keySelect, comparison, true);
		}

		struct ThenByEnumerable<TSource, TEnum, TKey, TSubKey, TKeyDlg, TCompare> : IEnumerator<TSource>, IEnumerable<TSource>, IDisposable
			where TEnum : concrete, IEnumerator<(TKey key, TSource value)>//, IDisposable
			where TKeyDlg : delegate TSubKey(TSource)
			where TCompare : delegate int(TSubKey lhs, TSubKey rhs)
		{
			typealias sortedEnumerable = SubSortEnumerable< TEnum, TSource, TKey, TSubKey, TKeyDlg, TCompare>;
			sortedEnumerable mSorted;

			public this(TEnum enumerator, TKeyDlg key, TCompare compare, bool descending)
			{
				mSorted = .(enumerator, key, compare, descending);
			}

			public Result<TSource> GetNext() mut
			{
				if (mSorted.GetNext() case .Ok(let val))
					return .Ok(val.value);

				return .Err;
			}

			public Self GetEnumerator()
			{
				return this;
			}

			public void Dispose() mut
			{
				mSorted.Dispose();
			}

			/*internal SubSortEnumerable<TSource, decltype(default(Self).GetEnumerator()), TKey2,  TKey3, TKeyDlg2, TCompare2>
				Then<TEnum2, TKey3, TKeyDlg2, TCompare2>(TKeyDlg2 key, TCompare2 compare, bool descending)
				where TEnum2: concrete, IEnumerator<(TKey2 key, TSource value)>
				where TKeyDlg2: delegate TKey3(TSource)
				where TCompare2 : delegate int(TKey3 lhs, TKey3 rhs)
			{
				return .(mSorted.GetEnumerator(), key, compare, descending);
			}*/

			internal SubSortEnumerable<decltype(default(sortedEnumerable).GetEnumerator()),TSource, TSubKey,  TKey2, TKeyDlg2, TCompare2>
				ThenBy<TEnum2, TKey2, TKeyDlg2, TCompare2>(TKeyDlg2 key, TCompare2 compare, bool descending)
				where TEnum2: concrete, IEnumerator<(TKey key, TSource value)>
				where TKeyDlg2: delegate TKey2(TSource)
				where TCompare2 : delegate int(TKey2 lhs, TKey2 rhs)
			{
				return .(mSorted.GetEnumerator(), key, compare, descending);
			}
			
			internal SubSortEnumerable<decltype(default(sortedEnumerable).GetEnumerator()),TSource, TSubKey,  TKey2, TKeyDlg2, delegate int(TKey lhs, TKey rhs)>
				ThenBy<TEnum2, TKey2, TKeyDlg2>(TKeyDlg2 key)
				where TEnum2: concrete, IEnumerator<(TKey key, TSource value)>
				where TKeyDlg2: delegate TKey2(TSource)
				where int : operator TKey2 <=> TKey2
			{
				return .(mSorted.GetEnumerator(), key, OrderByComparison<TKey2>.Comparison, false);
			}
		}

		/*public static ThenByEnumerable<TSource, TEnum, TOrdered TKey, TKeyDlg, TCompare>
			ThenBy<TSource, TEnum, TKey, TKeyDlg, TCompare>(this OrderByEnumerable<TSource, TEnum, TKey, TKeyDlg, TCompare> items, TKeyDlg keySelect, TCompare comparison)
			where TEnum : concrete, IEnumerator<TSource>
			where TKeyDlg : delegate TKey(TSource)
			where TCompare : delegate int(TKey lhs, TKey rhs)
		{
			return .(items.GetEnumerator(), keySelect, comparison, false);
		}*/

		/*struct OfTypeEnumerable<TSource, TEnum, TOf> : Iterator<TEnum, TSource>, IEnumerator<TOf>, IEnumerable<TOf>
			where TEnum : concrete, IEnumerator<TSource>
			where TSource : class
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

		public static OfTypeEnumerable<TSource, decltype(default(TCollection).GetEnumerator()), TOf>
			OfType<TCollection, TSource, TOf>(this TCollection items)
			where TCollection : concrete, IEnumerable<TSource>
			where TSource : class
		{
			return .(items.GetEnumerator());
		}*/


	}
}
