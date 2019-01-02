import React from 'react'
import PropTypes from 'prop-types'

const AddWork = ({ addWork }) => {
  let input

  return (
    <div>
      <form onSubmit={e => {
        e.preventDefault()
        if (!input.value.trim()) {
          return
        }
        addWork(input.value)
        input.value = ''
      }}>
        <input ref={node => input = node} />
        <button type="submit">
          Add Work
        </button>
      </form>
    </div>
  )
}

AddWork.propTypes = {
  addWork: PropTypes.func.isRequired,
}

export default AddWork
