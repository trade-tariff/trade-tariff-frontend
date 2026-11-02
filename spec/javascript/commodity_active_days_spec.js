import {recordCommodityActiveDay} from '../../app/javascript/src/commodity-active-days';
const KEY='ott.commodity.active-days.v1';
function storage(initial){const data=new Map(initial===undefined?[]:[[KEY,initial]]);return {getItem:k=>data.get(k)??null,setItem:(k,v)=>data.set(k,v),data};}
describe('AI-1471 distinct commodity days',()=>{
 it('counts reloads and multiple commodities on one day once',()=>{
  const s=storage();for(let i=0;i<5;i++)expect(recordCommodityActiveDay(new Date('2026-11-02T12:00:00Z'),s)).toBe(1);
 });
 it('qualifies three distinct days rather than three sessions',()=>{
  const s=storage();for(const [i,day]of ['2026-10-30','2026-11-01','2026-11-02'].entries())expect(recordCommodityActiveDay(new Date(day+'T12:00:00Z'),s)).toBe(i+1);
 });
 it('includes today and the preceding 27 dates, excluding day 29',()=>{
  const s=storage(JSON.stringify(['2026-10-05','2026-10-06','2026-11-01']));
  expect(recordCommodityActiveDay(new Date('2026-11-02T12:00:00Z'),s)).toBe(3);
  expect(JSON.parse(s.getItem(KEY))).toEqual(['2026-10-06','2026-11-01','2026-11-02']);
 });
 it('uses London calendar midnight in British Summer Time',()=>{
  const s=storage();expect(recordCommodityActiveDay(new Date('2026-06-01T22:59:00Z'),s)).toBe(1);
  expect(recordCommodityActiveDay(new Date('2026-06-01T23:01:00Z'),s)).toBe(2);
 });
 it('treats the repeated autumn hour as one calendar date',()=>{
  const s=storage();expect(recordCommodityActiveDay(new Date('2026-10-25T00:30:00Z'),s)).toBe(1);
  expect(recordCommodityActiveDay(new Date('2026-10-25T01:30:00Z'),s)).toBe(1);
 });
 it('ignores malformed, duplicate, impossible and future dates',()=>{
  const s=storage(JSON.stringify(['PRIVATE','2026-02-30','2026-11-01','2026-11-01','2026-11-03',1]));
  expect(recordCommodityActiveDay(new Date('2026-11-02T12:00:00Z'),s)).toBe(2);
 });
 it('resets malformed JSON safely without emitting its contents',()=>{
  const s=storage('PRIVATE');expect(recordCommodityActiveDay(new Date('2026-11-02T12:00:00Z'),s)).toBe(1);
  expect(s.getItem(KEY)).toBe('["2026-11-02"]');
 });
 it('returns unknown when storage is blocked rather than fabricating activity',()=>{
  const s={getItem(){throw new Error('Blocked')}};expect(recordCommodityActiveDay(new Date('2026-11-02T12:00:00Z'),s)).toBeUndefined();
 });
});
