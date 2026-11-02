// AI-1471: anonymous browser-local dates only. Call only after analytics consent.
export const COMMODITY_ACTIVE_DAYS_KEY = 'ott.commodity.active-days.v1';

export function recordCommodityActiveDay(date = new Date(), storage) {
  try {
    const store = storage ?? window.localStorage;
    const parts = new Intl.DateTimeFormat('en-GB', {
      timeZone: 'Europe/London', year: 'numeric', month: '2-digit', day: '2-digit',
    }).formatToParts(date);
    const value = (type) => parts.find((part) => part.type === type).value;
    const today = `${value('year')}-${value('month')}-${value('day')}`;
    const todayTime = Date.parse(`${today}T00:00:00Z`);
    const cutoff = todayTime - 27 * 86400000;
    let previous;
    try { previous = JSON.parse(store.getItem(COMMODITY_ACTIVE_DAYS_KEY) ?? '[]'); }
    catch { previous = []; }
    const valid = (day) => {
      if (typeof day !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(day)) return false;
      const time = Date.parse(`${day}T00:00:00Z`);
      return Number.isFinite(time) && new Date(time).toISOString().slice(0, 10) === day && time >= cutoff && time <= todayTime;
    };
    const days = [...new Set([...(Array.isArray(previous) ? previous.filter(valid) : []), today])].sort();
    store.setItem(COMMODITY_ACTIVE_DAYS_KEY, JSON.stringify(days));
    return days.length;
  } catch { return undefined; }
}

export function clearCommodityActiveDays(storage) {
  try { (storage ?? window.localStorage).removeItem(COMMODITY_ACTIVE_DAYS_KEY); }
  catch { /* Blocked storage must not weaken the consent gate. */ }
}
