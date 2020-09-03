import React from 'react'
import { render } from '@testing-library/react'
import App from './App'

test('Renders a friendly message', () => {
  const { getByText } = render(<App />)
  const expectedMessage = 'Hello!'

  expect(getByText(expectedMessage)).toBeTruthy()
})
