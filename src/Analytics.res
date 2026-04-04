// Blue Screen of App - Analytics Module (ReScript)
// In-memory analytics tracking

type stats = {
  mutable totalVisits: int,
  mutable styleViews: Js.Dict.t<int>,
  mutable errorCodeViews: Js.Dict.t<int>,
  mutable customMessages: int,
  mutable apiCalls: int,
  startTime: float,
}

// Singleton instance
let analytics: stats = {
  totalVisits: 0,
  styleViews: Js.Dict.empty(),
  errorCodeViews: Js.Dict.empty(),
  customMessages: 0,
  apiCalls: 0,
  startTime: Js.Date.now(),
}

// Helper to increment dictionary value
let incrementDict = (dict: Js.Dict.t<int>, key: string): unit => {
  let current = Js.Dict.get(dict, key)->Belt.Option.getWithDefault(0)
  Js.Dict.set(dict, key, current + 1)
}

// Track a page visit
@genType
let trackVisit = (style: string, errorCode: string, isCustom: bool): unit => {
  analytics.totalVisits = analytics.totalVisits + 1
  incrementDict(analytics.styleViews, style)
  incrementDict(analytics.errorCodeViews, errorCode)

  if isCustom {
    analytics.customMessages = analytics.customMessages + 1
  }
}

// Track an API call
@genType
let trackApiCall = (): unit => {
  analytics.apiCalls = analytics.apiCalls + 1
}

// Get current statistics
@genType
let getStats = (): stats => analytics

// Get uptime in seconds
@genType
let getUptime = (): float => {
  (Js.Date.now() -. analytics.startTime) /. 1000.0
}

// Reset statistics (development only)
@genType
let resetStats = (): unit => {
  analytics.totalVisits = 0
  analytics.styleViews = Js.Dict.empty()
  analytics.errorCodeViews = Js.Dict.empty()
  analytics.customMessages = 0
  analytics.apiCalls = 0
}

// Export stats as JSON-friendly object
@genType
let getStatsObject = (): {
  "totalVisits": int,
  "styleViews": Js.Dict.t<int>,
  "errorCodeViews": Js.Dict.t<int>,
  "customMessages": int,
  "apiCalls": int,
  "uptime": float,
} => {
  "totalVisits": analytics.totalVisits,
  "styleViews": analytics.styleViews,
  "errorCodeViews": analytics.errorCodeViews,
  "customMessages": analytics.customMessages,
  "apiCalls": analytics.apiCalls,
  "uptime": getUptime(),
}
