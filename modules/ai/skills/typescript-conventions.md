---
name: typescript-conventions
description: Conventions for TypeScript code style, types, and patterns. Use when writing or reviewing TypeScript code, including in Svelte projects.
---

# TypeScript Conventions

## Naming

- `snake_case` for non-exported variables and functions
- `camelCase` for publicly exported functions
- `PascalCase` for types, interfaces, and classes
- `snake_case` for class properties and methods
- `UPPER_SNAKE_CASE` for constants
- `snake_case` for file names

## Formatting

Tabs, double quotes, no trailing commas, semicolons.

## Return Types

Always use explicit return types. They catch incorrect returns and speed up type checking.

## Runtime Validation

Never hard cast from `JSON.parse`. Validate at runtime:

```typescript
function isMyType(value: unknown): value is MyType {
    return typeof value === "object" &&
        value !== null &&
        typeof (<MyType>value).prop === "string";
}

const value = JSON.parse(message);
assert(isMyType(value), "Invalid message format");
```

Type assertion functions take `unknown`, return `boolean`, never throw. Use with `assert`.

## Interfaces vs Types

- `interface` for module-scope object shapes
- `type` for unions, intersections, and modifications of existing types
- No `I` prefix or `Data` suffix
- Properties in alphabetical order
- Think of interfaces as nouns or adjectives (`Shippable`, `Refundable`)

## Casting

Always use `as` syntax, never angle brackets.

## Enums

Never use TypeScript enums. Use objects with inferred value types:

```typescript
export const OrderStatus = {
    confirmed: "confirmed",
    paid: "paid",
    shipped: "shipped"
};

export type OrderStatus = (typeof OrderStatus)[keyof typeof OrderStatus];
```

## Type Shadowing

Shadowing is preferred for enum-style objects (above) and Zod schemas:

```typescript
export const Product = z.object({
    id: z.string(),
    name: z.string(),
    price: z.number().min(0)
});

export type Product = z.infer<typeof Product>;
```

Do not shadow in other cases.

## Iteration

Use `for...of` for side effects. Use `map`/`filter`/`reduce` for transformations.

## Organisation

- Keep types with related code, not in `types/` directories
- Only export types that are part of the public API
- Use `ReturnType` and `Parameters` to access private types
